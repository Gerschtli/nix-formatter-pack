{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.tools.statix;

  configFile = pkgs.writeTextFile {
    name = "statix-config";
    destination = "/statix.toml";
    text = ''
      disabled = [
      ${concatMapStringsSep "\n" (l: "  \"${l}\",") cfg.disabledLints}
      ]
    '';
  };
in

{
  options = {

    tools.statix = {
      enable = mkEnableOption "statix";

      disabledLints = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Disabled lints, see
          <link xlink:href="https://github.com/nerdypepper/statix#configuration">offical statix docs</link>
          for list of all available lints.

          </para><para>

          <emphasis>Note</emphasis>: When this option is used, no other config file will be
          read by statix.
        '';
      };

      unrestricted = mkOption {
        type = types.bool;
        default = false;
        description = "Don't respect <filename>.gitignore</filename> files.";
      };
    };

  };

  config = mkIf cfg.enable {

    formatters.statix.commandFn =
      { checkOnly, files, ... }:
      concatStringsSep " " [
        "${pkgs.statix}/bin/statix"
        (if checkOnly then "check" else "fix")
        (optionalString (cfg.disabledLints != [ ]) "--config ${configFile}")
        (optionalString cfg.unrestricted "--unrestricted")
        files
      ];

  };
}
