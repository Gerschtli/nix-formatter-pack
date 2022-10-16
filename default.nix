{ nixpkgs ? null
, system ? null
, pkgs ? nixpkgs.legacyPackages.${system}
, config ? { }
, extraModules ? [ ]
, checkFiles ? [ ]
}:

assert pkgs != null;

let
  toolsModules = builtins.filter (pkgs.lib.hasSuffix ".nix") (pkgs.lib.filesystem.listFilesRecursive ./tools);

  modules = [
    { _module.args = { inherit pkgs; }; }
    ./module.nix
    "${pkgs.path}/nixos/modules/misc/assertions.nix"
    config
  ]
  ++ toolsModules
  ++ extraModules;

  evaluatedModules = pkgs.lib.evalModules { inherit modules; };

  check = pkgs.runCommand "nix-formatter-pack-check" { } ''
    ${evaluatedModules.config.script}/bin/nix-formatter-pack --check ${pkgs.lib.concatStringsSep " " checkFiles}
    touch ${placeholder "out"}
  '';
in

{
  inherit (evaluatedModules.config) script;
  inherit (evaluatedModules) config options;
  inherit check modules;
}
