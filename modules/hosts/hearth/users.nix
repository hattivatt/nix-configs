{ inputs, ... }:
{
  flake.modules.nixos.hearth =
  { pkgs, ... }:
  {
    users = {
      mutableUsers = false;
      users = {
        root.hashedPassword = "!";
        hattivatt = {
          uid = 1000;
          isNormalUser = true;
          createHome = true;
          hashedPassword = "!";
          openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9KxAw6E4ZY82Hh83tQUBcomPanlJ6pvIURZnULzDK3"
          ];
          description = "Vladimir";
          extraGroups = [ "wheel" "docker" ];
          shell = pkgs.bash;
        };
      };
    };
    home-manager = {
      extraSpecialArgs = {inherit inputs;};
    };
  };
}
