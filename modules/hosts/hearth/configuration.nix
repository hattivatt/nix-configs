{ inputs, ... }:
{
  flake.modules.nixos.hearth =
  { pkgs, ... }:
  {
    imports = with inputs.self.modules.nixos; [
      system-desktop
      systemd-boot
      bluetooth
      networkmanager
      preservation
    ];
    boot.kernelPackages = pkgs.linuxPackages_zen;
    time.timeZone = "Asia/Ho_Chi_Minh";
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = with pkgs; pinentry-qt;
    };
    security.sudo.extraConfig = ''
      Defaults pwfeedback
      Defaults lecture=never
    '';
  };
}

