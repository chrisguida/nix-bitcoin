let
  nixpkgsPinned = import ./nixpkgs-pinned.nix;
in
# Set default values for use without flakes
{ pkgs ? import <nixpkgs> { config = {}; overlays = []; }
, pkgsUnstable ? import nixpkgsPinned.nixpkgs-unstable {
    inherit (pkgs.stdenv) system;
    config = {};
    overlays = [];
  }
}:
let self = {
  bitcoind-mutinynet = self.bitcoind.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "benthecarman";
      repo = "bitcoin";
      rev = "d8434da3c14ed6723d86ef2cd266008d366e1413";
      sha256 = "sha256-Y3PjlKcH5DpfT+d2YAwPylNDJExB8Z0C0E4SB/Lt3vY=";
    };
  });

  clightning-rest = pkgs.callPackage ./clightning-rest { inherit (self) fetchNodeModules; };
  clboss = pkgs.callPackage ./clboss { };
  clightning-plugins = pkgs.recurseIntoAttrs (import ./clightning-plugins pkgs self.nbPython3Packages);
  joinmarket = pkgs.callPackage ./joinmarket { inherit (self) nbPython3PackagesJoinmarket; };
  lndinit = pkgs.callPackage ./lndinit { };
  liquid-swap = pkgs.python3Packages.callPackage ./liquid-swap { };
  rtl = pkgs.callPackage ./rtl { inherit (self) fetchNodeModules; };
  inherit (pkgs.callPackage ./mempool { inherit (self) fetchNodeModules; })
    mempool-backend
    mempool-frontend
    mempool-nginx-conf;
  trustedcoin = pkgs.callPackage ./trustedcoin { };

  pyPkgs = import ./python-packages self pkgs.python3;
  inherit (self.pyPkgs)
    nbPython3Packages
    nbPython3PackagesJoinmarket;

  fetchNodeModules = pkgs.callPackage ./build-support/fetch-node-modules.nix { };

  # Internal pkgs
  netns-exec = pkgs.callPackage ./netns-exec { };
  krops = import ./krops { inherit pkgs; };

  # Deprecated pkgs
  generate-secrets = import ./generate-secrets-deprecated.nix;
  nixops19_09 = pkgs.callPackage ./nixops { };

  pinned = import ./pinned.nix pkgs pkgsUnstable;

  modulesPkgs = self // self.pinned;
}; in self
