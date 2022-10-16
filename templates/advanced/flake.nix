{
  description = "Advanced usage example of nix-formatter-pack.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
  };

  outputs = { self, nixpkgs, nix-formatter-pack }:
    let
      forEachSystem = nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "i686-linux" "x86_64-darwin" "x86_64-linux" ];

      formatterPackArgsPerSystem = forEachSystem (system: {
        inherit nixpkgs system;
        # or a custom instance of nixpkgs:
        # pkgs = import nixpkgs { inherit system; };

        # extensible with custom modules:
        # extraModules = [ otherFlake.nixFormatterPackModules.default ];

        checkFiles = [ ./. ];

        config = {
          # define custom formatters:
          # formatters.customFormatter.commandFn =
          #   { checkOnly, files, ... }:
          #   ''
          #     ${customFormatter}/bin/customFormatter ${if checkOnly then "--check" else "--fix"} ${files}
          #   '';

          tools = {
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        };
      });
    in

    {
      checks = forEachSystem (system: {
        nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck formatterPackArgsPerSystem.${system};
      });

      formatter = forEachSystem (system: nix-formatter-pack.lib.mkFormatter formatterPackArgsPerSystem.${system});
    };
}
