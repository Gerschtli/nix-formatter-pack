{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.tools.deadnix;
in

{
  options = {

    tools.deadnix = {
      enable = mkEnableOption "deadnix";

      checkHiddenFiles = mkOption {
        type = types.bool;
        default = false;
        description = "Recurse into hidden subdirectories and process hidden `.*.nix` files.";
      };

      noLambdaArg = mkOption {
        type = types.bool;
        default = false;
        description = "Don't check lambda parameter arguments.";
      };

      noLambdaPatternNames = mkOption {
        type = types.bool;
        default = false;
        description = "Don't check lambda attrset pattern names (don't break nixpkgs callPackage).";
      };

      noUnderscore = mkOption {
        type = types.bool;
        default = false;
        description = "Don't check any bindings that start with a `_`.";
      };
    };

  };

  config = mkIf cfg.enable {

    formatters.deadnix.commandFn =
      { checkOnly, files, ... }:
      concatStringsSep " " [
        "${pkgs.deadnix}/bin/deadnix"
        (if checkOnly then "--fail" else "--edit")
        (optionalString cfg.checkHiddenFiles "--hidden")
        (optionalString cfg.noLambdaArg "--no-lambda-arg")
        (optionalString cfg.noLambdaPatternNames "--no-lambda-pattern-names")
        (optionalString cfg.noUnderscore "--no-underscore")
        files
      ];

  };
}
