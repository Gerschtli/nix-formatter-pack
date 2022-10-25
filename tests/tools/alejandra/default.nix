import ../default/lib.nix {
  name = "alejandra";
  configuration.tools.alejandra.enable = true;
  validFile = ./files/valid.nix.raw;
  invalidFile = ./files/invalid.nix.raw;
}
