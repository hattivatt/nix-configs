{
  flake.modules.homeManager.system-minimal =
    { lib, ... }:
    {
      options.my.persist = {
        directories = lib.mkOption {
          type = with lib.types; listOf (either str (attrsOf anything));
          default = [ ];
        };
        files = lib.mkOption {
          type = with lib.types; listOf (either str (attrsOf anything));
          default = [ ];
        };
      };
    };
}

