{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.tools.nixfmt;
in

{
  options = {

    tools.nixfmt = {
      enable = mkEnableOption "nixfmt";

      maxWidth = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Maximum width in characters.";
      };
    };

  };

  config = mkIf cfg.enable {

    formatters.nixfmt.commandFn =
      { checkOnly, files, ... }:
      "${pkgs.writeShellScript
        "nixmft"
        ''
          shopt -s globstar

          FILES=()
          for path in "$@"; do
            if [[ -d "$path" ]]; then
              FILES+=("$path"/**/*.nix)
            else
              FILES+=("$path")
            fi
          done

          ${pkgs.nixfmt}/bin/nixfmt \
            ${optionalString checkOnly "--check"} \
            ${optionalString (cfg.maxWidth != null) "--width ${toString cfg.maxWidth}"} \
            "''${FILES[@]}"
        ''
      } ${files}";

  };
}
