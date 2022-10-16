{ lib, config, ... }:

with lib;

let
  cfg = config.toolTest;
in

{
  options = {

    toolTest = {
      enable = mkEnableOption "tool test helper";

      checkOnly = mkOption {
        type = types.bool;
        description = "Whether to run in check or fix mode.";
      };

      files = mkOption {
        type = types.attrsOf (types.submodule (
          { config, name, ... }:
          {
            options = {
              name = mkOption {
                type = types.str;
                default = name;
                description = "Name of file.";
              };

              source = mkOption {
                type = types.path;
                description = "Source file.";
              };

              expected = mkOption {
                type = types.path;
                default = config.source;
                description = "Expected file. Defaults to `source` to ensure that the file did not change.";
              };
            };
          }
        ));
        description = "Files for the test and its assertions.";
      };

      expectedExitCode = mkOption {
        type = types.int;
        description = "Expected exit code of `nix-formatter-pack`.";
      };
    };

  };

  config = mkIf cfg.enable {

    nmt.script = ''
      mkdir -p $out/files
      ${concatMapStrings (file: ''
        cp "${file.source}" "$out/files/${file.name}"
      '') (attrValues cfg.files)}
      chmod --recursive +w $out/files

      $TESTED/bin/nix-formatter-pack ${optionalString cfg.checkOnly "--check"} ${concatMapStringsSep " " (file: "\"$out/files/${file.name}\"") (attrValues cfg.files)}; EXIT_CODE=$?

      if (( EXIT_CODE != ${toString cfg.expectedExitCode} )); then
        fail "Expected exit code to be ${toString cfg.expectedExitCode}, got $EXIT_CODE."
      fi

      ${concatMapStrings (file: ''
        assertFileContent "$out/files/${file.name}" "${file.expected}"
      '') (attrValues cfg.files)}
    '';

  };
}
