{
  description = "Collection of several nix formatters.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    nmt = {
      url = "gitlab:rycee/nmt";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nmt }:
    let
      forEachSystem = nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "i686-linux" "x86_64-darwin" "x86_64-linux" ];
      optiniatedDefaultConfig = {
        tools = {
          deadnix.enable = true;
          nixpkgs-fmt.enable = true;
          statix.enable = true;
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
          [ "deadnix" "nixfmt" "nixpkgs-fmt" "statix" ]
          (tool: mkFormatterApp {
            inherit nixpkgs system;
            config.tools.${tool}.enable = true;
          })
      );

      checks = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system: {
        nix-formatter-pack-check = self.lib.mkCheck {
          inherit nixpkgs system;
          config = optiniatedDefaultConfig;
          checkFiles = [ ./. ];
        };

        tests = import ./tests {
          inherit nixpkgs nmt system;
        };
      });

      formatter = forEachSystem (system:
        self.lib.mkFormatter {
          inherit nixpkgs system;
          config = optiniatedDefaultConfig;
        }
      );

      lib = {
        mkCheck = args: (import ./. args).check;
        mkFormatter = args: (import ./. args).script;
      };
    };
}
