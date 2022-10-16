_: {
  configuration.tools.deadnix = {
    enable = true;
    checkHiddenFiles = true;
    noLambdaArg = true;
    noLambdaPatternNames = true;
    noUnderscore = true;
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
