_: {
  configuration.tools.nixfmt = {
    enable = true;
    maxWidth = 80;
  };

  toolTest = {
    enable = true;
    checkOnly = false;
    files."valid.nix" = {
      source = ./files/valid.nix.raw;
    };
    expectedExitCode = 0;
  };
}
