{ name, configuration, validFile, invalidFile }@args:

{
  "${name}-check-fails-for-invalid-file" = import ./check-fails-for-invalid-file.nix args;
  "${name}-check-succeeds-for-valid-file" = import ./check-succeeds-for-valid-file.nix args;
  "${name}-format-succeeds-for-invalid-file" = import ./format-succeeds-for-invalid-file.nix args;
  "${name}-format-succeeds-for-valid-file" = import ./format-succeeds-for-valid-file.nix args;
}
