{ inputs, ... }:
{
  flake.homeConfigurations = inputs.self.lib.mkHomeManagerSA "x86_64-linux" "thehat";
}
