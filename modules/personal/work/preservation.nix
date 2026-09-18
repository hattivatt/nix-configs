{
  flake.modules.homeManager.work = {
    my.persist.directories = [
      ".cache/terragrunt"
      ".kube"
      ".tenv"
      ".config/lazyjira"
    ];
  };
}
