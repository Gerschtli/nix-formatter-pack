{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.tools.nixpkgs-fmt;
in

{
  options = {

    tools.nixpkgs-fmt = {
      enable = mkEnableOption "nixpkgs-fmt";
    };

  };

  config = mkIf cfg.enable {

    formatters.nixpkgs-fmt.commandFn =
      { checkOnly, files, ... }:
      ''
        ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt ${optionalString checkOnly "--check"} ${files}
      '';

  };
}
