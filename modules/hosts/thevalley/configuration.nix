{ inputs, ... }:
{
  flake.modules.nixos.thevalley =
  { pkgs, ... }:
  let
    resolvectl = "${pkgs.systemd}/bin/resolvectl";
  in
  {
    imports = with inputs.self.modules.nixos; [
      system-desktop
      systemd-boot
      bluetooth
      networkmanager
      preservation
    ];
    boot = {
      kernelPackages = pkgs.linuxPackages_zen;
      zswap.enable = true;
      kernel.sysctl = {
        "vm.swappiness" = 180;
      };
    };
    time.timeZone = "Asia/Ho_Chi_Minh";
    networking.hostName = "thevalley";
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = with pkgs; pinentry-qt;
    };
    services = {
      upower.enable = true;
      # pppd.enable = true;
    };
    security.sudo.extraConfig = ''
      Defaults pwfeedback
      Defaults lecture=never
    '';
    environment.etc."ppp/ip-up" = {
      mode = "0755";
      text = ''
        #!${pkgs.bash}/bin/bash
        # args: iface tty speed local-ip remote-ip ipparam
        # DNS1/DNS2 выставляет pppd при usepeerdns
        [ -n "$DNS1" ] && ${resolvectl} dns "$1" $DNS1 $DNS2
        ${resolvectl} domain "$1" "~zvq.me"
        ${resolvectl} default-route "$1" true
      '';
    };
    environment.etc."ppp/ip-down" = {
      mode = "0755";
      text = ''
        #!${pkgs.bash}/bin/bash
        ${resolvectl} revert "$1"
      '';
    };
  };
}
