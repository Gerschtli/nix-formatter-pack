import ../default/lib.nix {
  name = "nixpkgs-fmt";
  configuration.tools.nixpkgs-fmt.enable = true;
  validFile = ./files/valid.nix.raw;
  invalidFile = ./files/invalid.nix.raw;
}
