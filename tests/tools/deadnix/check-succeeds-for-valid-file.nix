_: {
  configuration.tools.deadnix.enable = true;

  toolTest = {
    enable = true;
    checkOnly = true;
    files."valid.nix" = {
      source = ./files/valid.nix.raw;
    };
    expectedExitCode = 0;
  };
}
