(import ../default/lib.nix {
  name = "statix";
  configuration.tools.statix.enable = true;
  validFile = ./files/valid.nix.raw;
  invalidFile = ./files/invalid.nix.raw;
}) // {
  statix-format-succeeds-with-all-options = import ./format-succeeds-with-all-options.nix;
}
