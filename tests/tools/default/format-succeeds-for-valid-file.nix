{ configuration, validFile, ... }:

_:

{
  inherit configuration;

  toolTest = {
    enable = true;
    checkOnly = false;
    files."valid.nix" = {
      source = validFile;
    };
    expectedExitCode = 0;
  };
}
