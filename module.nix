{ pkgs, lib, config, ... }:

with lib;

let
  enabledFormatters = filter (f: f.enable) (attrValues config.formatters);

  buildCommand = commandFn: checkOnly:
    let
      command = commandFn {
        inherit checkOnly;
        files = "\"\${FILE_PATHS[@]}\"";
      };
    in
    "${command} || LOCAL_RESULT=$?";

  commands =
    concatMapStringsSep
      "\n"
      (formatter: ''
        logInfo "Running ${formatter.name}..."
        LOCAL_RESULT=0
        if [[ -n "$CHECK_ONLY" ]]; then
          ${buildCommand formatter.commandFn true}
        else
          ${buildCommand formatter.commandFn false}
        fi

        if (( LOCAL_RESULT > 0 )); then
          RESULT=1
          logWarn "Failed with exit code: $LOCAL_RESULT"
        fi

        echo
      '')
      enabledFormatters;

  script = pkgs.writeShellApplication {
    name = "nix-formatter-pack";
    runtimeInputs = with pkgs; [ ncurses ];

    text = ''
      COLOR_RESET=
      COLOR_ERROR=
      COLOR_WARN=
      COLOR_INFO=
      if [[ -t 1 ]]; then
        COLOR_RESET="$(tput sgr0)"
        COLOR_ERROR="$(tput bold)$(tput setaf 1)"
        COLOR_WARN="$(tput setaf 3)"
        COLOR_INFO="$(tput bold)$(tput setaf 6)"
      fi

      function logError() {
        echo >&2 "$COLOR_ERROR$*$COLOR_RESET"
      }

      function logWarn() {
        echo "$COLOR_WARN$*$COLOR_RESET"
      }

      function logInfo() {
        echo "$COLOR_INFO$*$COLOR_RESET"
      }

      function doHelp() {
        echo "Usage: $0 [OPTION] [--] FILES"
        echo
        echo "Formats nix source files. Enabled formatters are ${concatMapStringsSep ", " (f: "'${f.name}'") enabledFormatters}."
        echo
        echo "Options"
        echo
        echo "  -h|--help         Print this help"
        echo "  -c|--check        Check only (useful for CI)"
      }

      CHECK_ONLY=
      FILE_PATHS=()
      RESULT=0

      while [[ $# -gt 0 ]]; do
        opt="$1"
        shift
        case "$opt" in
          -c|--check)
            CHECK_ONLY=1
            ;;
          -h|--help)
            doHelp
            exit 0
            ;;
          --)
            FILE_PATHS+=("$@")
            break
            ;;
          -*)
            logError "$0: unknown option '$opt'"
            logError "Run '$0 --help' for usage help"
            exit 2
            ;;
          *)
            FILE_PATHS+=("$opt")
            ;;
        esac
      done

      # default to current directory
      if [[ "''${#FILE_PATHS[@]}" -eq 0 ]]; then
        FILE_PATHS+=(.)
      fi

      ${commands}

      exit $RESULT
    '';
  };

  failedAssertions = map (x: x.message) (filter (x: !x.assertion) config.assertions);
  throwAssertions = res:
    if (failedAssertions != [ ])
    then throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
    else res;
in

{
  options = {
    formatters = mkOption {
      type = types.attrsOf (types.submodule (
        { name, ... }:
        {
          options = {
            enable = mkEnableOption "formatter" // { default = true; };

            name = mkOption {
              type = types.str;
              default = name;
              description = "Name of formatter.";
            };

            commandFn = mkOption {
              type = types.functionTo types.singleLineStr;
              example = literalExpression ''
                { checkOnly, files, ... }:
                '''
                  ''${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt ''${lib.optionalString checkOnly "--check"} ''${files}
                '''
              '';
              description = ''
                Command for formatter. Receives at least <varname>checkOnly</varname> as boolean
                and <varname>files</varname> as a string.

                Must return a non-zero exit code when <varname>checkOnly</varname> is true and the
                check fails. Should return zero exit code when <varname>checkOnly</varname> is false
                and all issues could be fixed.

                For more complex commands, use <varname>pkgs.writeScript</varname> like
                <programlisting language="nix">
                { checkOnly, files, ... }:
                "''${pkgs.writeScript
                  "nixpkgs-fmt"
                  '''
                    ''${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt ''${lib.optionalString checkOnly "--check"} "$@"
                  '''
                } ''${files}";
                </programlisting>
              '';
            };
          };
        }
      ));
      default = { };
      description = "Set of all formatters to run on script execution.";
    };

    script = mkOption {
      type = types.package;
      internal = true;
      readOnly = true;
      description = "Final script.";
    };
  };

  config = {

    assertions = [
      {
        assertion = enabledFormatters != [ ];
        message = "At least one formatter needs to be enabled.";
      }
    ];

    script = throwAssertions (showWarnings config.warnings script);

  };
}
