{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.tools.alejandra;
in

{
  options = {

    tools.alejandra = {
      enable = mkEnableOption "alejandra";
    };

  };

  config = mkIf cfg.enable {

    formatters.alejandra.commandFn =
      { checkOnly, files, ... }:
      ''
        ${pkgs.alejandra}/bin/alejandra ${optionalString checkOnly "--check"} ${files}
      '';

  };
}
