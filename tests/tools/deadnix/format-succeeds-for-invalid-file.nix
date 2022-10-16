_: {
  configuration.tools.deadnix.enable = true;

  toolTest = {
    enable = true;
    checkOnly = false;
    files."invalid.nix" = {
      source = ./files/invalid.nix.raw;
      expected = ./files/valid.nix.raw;
    };
    expectedExitCode = 0;
  };
}
