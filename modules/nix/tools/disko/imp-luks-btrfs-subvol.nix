{ inputs, ... }:
{
  flake.modules.nixos.disko-imp-luks-btrfs-subvol =
  {
    imports = with inputs.self.modules.nixos; [
      disko-common
    ];
    fileSystems."/persist".neededForBoot = true;
    fileSystems."/nix".neededForBoot = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.luks.devices."crypted" = {
      device = "/dev/disk/by-partlabel/disk-main-luks";
      preLVM = true;
      allowDiscards = true;
      bypassWorkqueues = true;
    };
    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root; keep last 3 old roots";
      wantedBy = [ "initrd.target" ];
      after = [ "systemd-cryptsetup@crypted.service" ];
      before = [ "sysroot.mount" ];
      unitConfig = {
        DefaultDependencies = "no";
        ConditionKernelCommandLine = "!resume=";
      };
      serviceConfig.Type = "oneshot";
      script = ''
        set -euo pipefail

        KEEP=3
        MNT=/btrfs_tmp
        DEV=/dev/mapper/crypted

        mkdir -p "$MNT"
        mount -o subvol=/ "$DEV" "$MNT"

        ROOT="$MNT/@root"
        # dir на top-level FS; old roots становятся nested subvolumes под @persist
        OLD="$MNT/@persist/old_roots"
        BLANK="$MNT/@root-blank"

        is_subvol() {
          [ -e "$1" ] || return 1
          [ "$(stat -c %i -- "$1" 2>/dev/null || echo 0)" = "256" ]
        }

        # nested first (paths from `btrfs subvolume list -o`), then self
        delete_subvol() {
          local target="$1"
          is_subvol "$target" || return 0

          # без set -e внутри: prune не должен ронять boot
          set +e
          if btrfs subvolume delete --recursive -- "$target" 2>/dev/null; then
            set -e
            return 0
          fi

          # fallback: дети → родитель (list -o path relative to FS root of this mount)
          local child rel
          while IFS= read -r rel; do
            [ -n "$rel" ] || continue
            # list path never starts with / on this mount layout
            delete_subvol "$MNT/$rel"
          done < <(
            btrfs subvolume list -o "$target" 2>/dev/null \
              | sed -n 's/^.* path //p'
          )

          btrfs subvolume delete -- "$target" 2>/dev/null \
            || btrfs subvolume delete -c -- "$target" 2>/dev/null \
            || printf 'rollback: WARN failed to delete %s\n' "$target" >&2
          set -e
        }

        # --- move current root out of the way ---
        if [ -e "$ROOT" ]; then
          mkdir -p "$OLD"
          ts="$(date --date="@$(stat -c %Y -- "$ROOT")" '+%Y-%m-%d_%H:%M:%S')"
          # коллизия timestamp (двойной reboot в ту же секунду)
          if [ -e "$OLD/$ts" ]; then
            ts="''${ts}_$$"
          fi
          mv -- "$ROOT" "$OLD/$ts"
        fi

        # --- prune: ошибки delete не фатальны ---
        if [ -d "$OLD" ]; then
          set +e
          count=0
          # newest first; только directory entries
          while IFS= read -r name; do
            [ -n "$name" ] || continue
            count=$((count + 1))
            if [ "$count" -gt "$KEEP" ]; then
              delete_subvol "$OLD/$name"
              # если delete оставил пустой dir-остаток — убрать
              rmdir -- "$OLD/$name" 2>/dev/null || true
            fi
          done < <(ls -1 "$OLD" 2>/dev/null | sort -r)
          set -e
        fi

        # --- new root (private; fatal if this fails) ---
        if [ -e "$BLANK" ]; then
          btrfs subvolume snapshot "$BLANK" "$ROOT"
        else
          btrfs subvolume create "$ROOT"
        fi

        umount "$MNT"
        rmdir "$MNT" 2>/dev/null || true
      '';
    };
    systemd.services.systemd-machine-id-commit = {
      unitConfig.ConditionPathIsMountPoint = [
        ""
        "/persist/etc/machine-id"
      ];
      serviceConfig.ExecStart = [
        ""
        "systemd-machine-id-setup --commit --root /persist"
      ];
    };
    disko.devices.disk.main.content.partitions.luks = {
      size = "100%";
      content = {
        type = "luks";
        name = "crypted";
        passwordFile = "/tmp/secret.key"; # Interactive
        settings = {
          allowDiscards = true;
        };
        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "@root" = {
              mountpoint = "/";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
            "@nix" = {
              mountpoint = "/nix";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
            "@persist" = {
              mountpoint = "/persist";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
            "@swap" = {
              mountpoint = "/.swapvol";
            };
          };
        };
      };
    };
  };
}
