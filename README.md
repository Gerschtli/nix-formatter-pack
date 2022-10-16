# Nix formatter pack

With this project you can combine the simplicity of [`nix fmt`][nix-fmt-manual] with several static code analysis and
formatting tools.

Currently supported tools:

- [deadnix][deadnix] (see [./tools/deadnix.nix](./tools/deadnix.nix) for options)
- [nixfmt][nixfmt] (see [./tools/nixfmt.nix](./tools/nixfmt.nix) for options)
- [nixpkgs-fmt][nixpkgs-fmt] (see [./tools/nixpkgs-fmt.nix](./tools/nixpkgs-fmt.nix) for options)
- [statix][statix] (see [./tools/statix.nix](./tools/statix.nix) for options)

## Usage

Set the special flake output `formatter` like the following:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
  };

  outputs = { self, nixpkgs, nix-formatter-pack }: {

    formatter.x86_64-linux = nix-formatter-pack.lib.mkFormatter {
      inherit nixpkgs;
      system = "x86_64-linux";
      # or a custom instance of nixpkgs:
      # pkgs = import nixpkgs { inherit system; };

      # extensible with custom modules:
      # extraModules = [ otherFlake.nixFormatterPackModules.default ];

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
    };

  };
}
```

With this configuration, `nix fmt` will format your complete flake with the configured tools. `nix fmt -- --check` only
reports if any tool found an issue and fails with a non-zero exit code if any issue has been found, recommended for
usage in CI.

For more information, see `nix fmt -- --help`.

[deadnix]: https://github.com/astro/deadnix
[nix-fmt-manual]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-fmt.html
[nixfmt]: https://github.com/serokell/nixfmt
[nixpkgs-fmt]: https://github.com/nix-community/nixpkgs-fmt
[statix]: https://github.com/nerdypepper/statix