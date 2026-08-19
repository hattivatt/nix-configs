{
  flake.modules.nixos.docker =
  {
    virtualisation.docker = {
      enable = true;
    };
    users.users.hattivatt.extraGroups = [ "docker" ];
  };
}
