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
          hashedPasswordFile = "/persist/passwd";
          description = "Vladimir";
          extraGroups = [ "networkmanager" "wheel" ];
          shell = pkgs.bash;
        };
      };
    };
    home-manager = {
      extraSpecialArgs = {inherit inputs;};
      users.hattivatt = {
        imports = with inputs.self.modules.homeManager; [
          system-desktop
          accounts
          keys
          work
        ];
      };
    };
  };
}
