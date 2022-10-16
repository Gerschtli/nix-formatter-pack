{ configuration, validFile, invalidFile, ... }:

_:

{
  inherit configuration;

  toolTest = {
    enable = true;
    checkOnly = false;
    files."invalid.nix" = {
      source = invalidFile;
      expected = validFile;
    };
    expectedExitCode = 0;
  };
}
