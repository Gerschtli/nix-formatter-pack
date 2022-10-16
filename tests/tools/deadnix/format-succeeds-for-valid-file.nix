_: {
  configuration.tools.deadnix.enable = true;

  toolTest = {
    enable = true;
    checkOnly = false;
    files."valid.nix" = {
      source = ./files/valid.nix.raw;
    };
    expectedExitCode = 0;
  };
}
