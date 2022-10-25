{ pkgs, nmdSrc, formatter }:

let
  nmd = import nmdSrc { inherit pkgs; };

  # Make sure the used package is scrubbed to avoid actually instantiating
  # derivations.
  setupModule = {
    _module.args.pkgs = pkgs.lib.mkForce (nmd.scrubDerivations "pkgs" pkgs);
  };

  modulesDocs = nmd.buildModulesDocs {
    modules = formatter.modules ++ [ setupModule ];
    moduleRootPaths = [ ../. ];
    mkModuleUrl = path: "https://github.com/Gerschtli/nix-formatter-pack/blob/master/${path}";
    channelName = "nix-formatter-pack";
    docBook.id = "nix-formatter-pack-options";
  };

  docs = nmd.buildDocBookDocs {
    pathName = "nix-formatter-pack";
    modulesDocs = [ modulesDocs ];
    documentsDirectory = ./.;
    chunkToc = ''
      <toc>
        <d:tocentry xmlns:d="http://docbook.org/ns/docbook" linkend="book-manual"><?dbhtml filename="index.html"?>
          <d:tocentry linkend="ch-options"><?dbhtml filename="nix-formatter-pack-options.html"?></d:tocentry>
        </d:tocentry>
      </toc>
    '';
  };
in

{
  inherit (docs) manPages;

  optionsJson = pkgs.symlinkJoin {
    name = "nix-formatter-pack-options-json";
    paths = [
      (modulesDocs.json.override {
        path = "share/doc/nix-formatter-pack/nix-formatter-pack-options.json";
      })
    ];
  };

  manualHtml = docs.html;
}
