{ nixpkgs ? import <nixpkgs> {}, compiler ? "integer-simple.ghcHaLVM240" }:
   (import ./default.nix { inherit nixpkgs compiler; }).env
