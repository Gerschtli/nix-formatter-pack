_: {
  configuration.tools.statix = {
    enable = true;
    disabledLints = [ "bool_comparison" ];
    unrestricted = true;
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
