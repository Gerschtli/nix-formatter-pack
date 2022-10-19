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

      filePathsArgs = mkOption {
        type = types.listOf types.str;
        default = map (f: f.name) (attrValues cfg.files);
        defaultText = literalExpression ''map (f: f.name) (attrValues config.toolTest.files)'';
        description = ''
          List of file paths to call `nix-formatter-pack` with. Defaults to all files listed in
          `toolTest.files` option.

          Note: Each value is prefixed with `$out/files`, the same directory where all files from
          `toolTest.files` are copied to.
        '';
      };

      expectedExitCode = mkOption {
        type = types.int;
        description = "Expected exit code of `nix-formatter-pack`.";
      };
    };

  };

  config = mkIf cfg.enable {

    nmt.script =
      let
        filesDir = "${placeholder "out"}/files";
        mappedFilePathsArgs = concatMapStringsSep " " (file: ''"${filesDir}/${file}"'') cfg.filePathsArgs;
      in
      ''
        mkdir -p ${filesDir}
        ${concatMapStrings (file: ''
          cp "${file.source}" "${filesDir}/${file.name}"
        '') (attrValues cfg.files)}
        chmod --recursive +w ${filesDir}

        $TESTED/bin/nix-formatter-pack ${optionalString cfg.checkOnly "--check"} ${mappedFilePathsArgs}; EXIT_CODE=$?

        if (( EXIT_CODE != ${toString cfg.expectedExitCode} )); then
          fail "Expected exit code to be ${toString cfg.expectedExitCode}, got $EXIT_CODE."
        fi

        ${concatMapStrings (file: ''
          assertFileContent "${filesDir}/${file.name}" "${file.expected}"
        '') (attrValues cfg.files)}
      '';

  };
}
