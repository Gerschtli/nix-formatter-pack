{ configuration, validFile, ... }:

_:

{
  inherit configuration;

  toolTest = {
    enable = true;
    checkOnly = true;
    files."valid.nix" = {
      source = validFile;
    };
    expectedExitCode = 0;
  };
}
