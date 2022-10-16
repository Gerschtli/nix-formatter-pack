{
  description = "Minimal usage example of nix-formatter-pack.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
  };

  outputs = { self, nixpkgs, nix-formatter-pack }:
    let
      system = "x86_64-linux";

      formatterPackArgs = {
        inherit nixpkgs system;
        checkFiles = [ ./. ];

        config.tools.nixpkgs-fmt.enable = true;
      };
    in

    {
      checks.${system}.nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck formatterPackArgs;

      formatter.${system} = nix-formatter-pack.lib.mkFormatter formatterPackArgs;
    };
}
