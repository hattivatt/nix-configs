{
  flake.modules.homeManager.shells = {
    my.persist.directories = [
      ".config/nushell"
      ".config/zsh"
      ".local/share/zoxide"
    ];
  };
}
