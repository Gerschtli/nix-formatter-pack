{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.tools.statix;
in

{
  options = {

    tools.statix = {
      enable = mkEnableOption "statix";
    };

  };

  config = mkIf cfg.enable {

    formatters.statix.commandFn =
      { checkOnly, files, ... }:
      ''
        ${pkgs.statix}/bin/statix ${if checkOnly then "check" else "fix"} ${files}
      '';

  };
}
