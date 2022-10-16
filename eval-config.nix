{ nixpkgs ? null
, system ? null
, pkgs ? nixpkgs.legacyPackages.${system}
, config ? { }
, extraModules ? [ ]
}:

assert pkgs != null;

let
  toolsModules = builtins.filter (pkgs.lib.hasSuffix ".nix") (pkgs.lib.filesystem.listFilesRecursive ./tools);

  modules = [
    {
      _file = ./eval-config.nix;
      _module.args = { inherit pkgs; };
    }
    ./module.nix
    "${pkgs.path}/nixos/modules/misc/assertions.nix"
    config
  ]
  ++ toolsModules
  ++ extraModules;

  evaluatedModules = pkgs.lib.evalModules { inherit modules; };
in

{
  inherit (evaluatedModules.config) script;
  inherit (evaluatedModules) config options;
  inherit modules;
}
