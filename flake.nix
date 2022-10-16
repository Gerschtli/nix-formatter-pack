{
  description = "Collection of several nix formatters.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";

  outputs = { self, nixpkgs }:
    let
      forEachSystem = nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "i686-linux" "x86_64-darwin" "x86_64-linux" ];
      optiniatedDefaultConfig = {
        tools = {
          deadnix.enable = true;
          nixpkgs-fmt.enable = true;
        };
      };

      mkFormatterApp = args: {
        type = "app";
        program = "${self.lib.mkFormatter args}/bin/nix-formatter-pack";
      };
    in
    {
      apps = forEachSystem (system:
        {
          default = mkFormatterApp {
            inherit nixpkgs system;
            config = optiniatedDefaultConfig;
          };
        }
        // nixpkgs.lib.genAttrs
          [ "deadnix" "nixpkgs-fmt" ]
          (tool: mkFormatterApp {
            inherit nixpkgs system;
            config.tools.${tool}.enable = true;
          })
      );

      formatter = forEachSystem (system:
        self.lib.mkFormatter {
          inherit nixpkgs system;
          config = optiniatedDefaultConfig;
        }
      );

      lib.mkFormatter = import ./eval-config.nix;
    };
}
