_: {
  configuration.tools.deadnix.enable = true;

  toolTest = {
    enable = true;
    checkOnly = true;
    files."invalid.nix" = {
      source = ./files/invalid.nix.raw;
    };
    expectedExitCode = 1;
  };
}
