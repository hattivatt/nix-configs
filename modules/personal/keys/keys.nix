{
  flake.modules.homeManager.keys =
  { inputs, pkgs, config, lib, ... }:
  {
    sops = {
      secrets."keys/my_ssh" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };
      secrets."keys/my_ssh_pub" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };
      secrets."keys/my_old" = {
        path = "${config.home.homeDirectory}/.ssh/id_rsa";
      };
      secrets."keys/my_old_pub" = {
        path = "${config.home.homeDirectory}/.ssh/id_rsa.pub";
      };
      secrets."keys/pass" = { };
    };
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
    home.activation.importGpgKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
      KEY_ID="9D25146C5C6D7CD16598853D7812F348399C7FF2"
      if ! $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --list-secret-keys "$KEY_ID" >/dev/null 2>&1; then
        if [ -f "${config.sops.secrets."keys/pass".path}" ]; then
          $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --batch --import "${config.sops.secrets."keys/pass".path}"
        else
          echo "sops keys/pass ещё не расшифрован, импорт gpg пропущен" >&2
        fi
      fi
    '';
  };
}
