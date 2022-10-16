{ configuration, invalidFile, ... }:

_:

{
  inherit configuration;

  toolTest = {
    enable = true;
    checkOnly = true;
    files."invalid.nix" = {
      source = invalidFile;
    };
    expectedExitCode = 1;
  };
}
