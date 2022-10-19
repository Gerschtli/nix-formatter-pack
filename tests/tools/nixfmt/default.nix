(import ../default/lib.nix {
  name = "nixfmt";
  configuration.tools.nixfmt.enable = true;
  validFile = ./files/valid.nix.raw;
  invalidFile = ./files/invalid.nix.raw;
}) // {
  nixfmt-format-succeeds-with-all-options = import ./format-succeeds-with-all-options.nix;
  nixfmt-formats-all-nix-files-in-directoy = import ./nixfmt-formats-all-nix-files-in-directoy.nix;
}
