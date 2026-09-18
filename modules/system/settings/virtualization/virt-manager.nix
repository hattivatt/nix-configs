{
  flake.modules.nixos.virt-manager =
  { pkgs, ... }:
  {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    users.users.hattivatt.extraGroups = [ "libvirtd" ];
    environment.systemPackages = with pkgs; [
      dnsmasq
    ];
    networking.firewall.trustedInterfaces = [ "virbr0" ];
  };
}
