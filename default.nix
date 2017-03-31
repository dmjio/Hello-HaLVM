{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghcHaLVM240" }:
let
  hpkgs = nixpkgs.pkgs.haskell.packages.integer-simple.${compiler}.override {
    overrides = self: super: with nixpkgs.pkgs.haskell.lib; {
      mkDerivation = args: super.mkDerivation (args // { hardeningDisable = ["stackprotector"]; });
      cryptonite = disableCabalFlag super.cryptonite "integer-gmp";
    };
  };
in hpkgs.callPackage ./hello-halvm.nix {}
