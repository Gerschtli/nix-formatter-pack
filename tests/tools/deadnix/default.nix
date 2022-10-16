(import ../default/lib.nix {
  name = "deadnix";
  configuration.tools.deadnix.enable = true;
  validFile = ./files/valid.nix.raw;
  invalidFile = ./files/invalid.nix.raw;
}) // {
  deadnix-format-succeeds-with-all-options = import ./format-succeeds-with-all-options.nix;
}
