_: {
  configuration.tools.nixfmt.enable = true;

  toolTest = {
    enable = true;
    checkOnly = false;
    files = {
      "file1.nix" = {
        source = ./files/invalid.nix.raw;
        expected = ./files/valid.nix.raw;
      };
      "file2.nix" = {
        source = ./files/invalid.nix.raw;
        expected = ./files/valid.nix.raw;
      };
      "file3.any" = {
        source = ./files/invalid.nix.raw;
        expected = ./files/invalid.nix.raw;
      };
    };
    filePathsArgs = [ "." ];
    expectedExitCode = 0;
  };
}
