{ nixpkgs
, system
, nmt
}:

let
  pkgs = nixpkgs.legacyPackages.${system};

  modules = [
    {
      _file = ./default.nix;
      _module.args = { inherit pkgs; };
    }
    ./module.nix
    ./tool-test.nix
  ];

  defaultNixFiles = builtins.filter (x: baseNameOf x == "default.nix") (pkgs.lib.filesystem.listFilesRecursive ./tools);

  nmtInstance = import nmt {
    inherit pkgs modules;
    testedAttrPath = [ "formatter" ];
    tests = builtins.foldl' (a: b: a // (import b)) { } defaultNixFiles;
  };
in

pkgs.runCommandLocal "tests" { } ''
  touch ${placeholder "out"}

  ${nmtInstance.run.all.shellHook}
''
