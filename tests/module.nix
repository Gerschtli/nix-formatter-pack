{ pkgs, lib, config, ... }:

with lib;

{
  options = {

    formatter = mkOption {
      type = types.package;
      description = "Formatter to use for the test.";
    };

    configuration = mkOption {
      type = types.submodule (import ../. { inherit pkgs; }).modules;
      description = "Nix formatter pack configuration to test.";
    };

  };

  config = {

    formatter = mkIf (config != null) config.configuration.script;

  };
}
