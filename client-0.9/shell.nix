{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghcjs" }:

let

  inherit (nixpkgs) pkgs;
  inherit (pkgs.haskell.packages) ghcjs;

  f = { mkDerivation, base, servant
      , servant-client, servant-server, stdenv, ghcjs, ghcjs-base, ghcjs-prim, warp, text, http-client, transformers
      }:
      mkDerivation {
        pname = "reproduceServant";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [
          base ghcjs-base ghcjs-prim servant servant-client servant-server warp text http-client transformers
        ];
        description = "Reproduce bugs in servant-client ghcjs";
        license = stdenv.lib.licenses.unfree;
      };

  drv = pkgs.haskell.packages.ghcjs.callPackage f {
    ghcjs = pkgs.haskell.compiler.ghcjs;
    ghcjs-base = ghcjs.ghcjs-base;
    ghcjs-prim = ghcjs.ghcjs-prim;
  };

in

  if pkgs.lib.inNixShell then drv.env else drv
