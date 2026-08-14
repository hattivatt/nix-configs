{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      ".cache/terragrunt"
      ".kube"
    ];
  };
}
