{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.tools.deadnix;
in

{
  options = {

    tools.deadnix = {
      enable = mkEnableOption "deadnix";
    };

  };

  config = mkIf cfg.enable {

    formatters.deadnix.commandFn =
      { checkOnly, files, ... }:
      ''
        ${pkgs.deadnix}/bin/deadnix ${if checkOnly then "--fail" else "--edit"} ${files}
      '';

  };
}
