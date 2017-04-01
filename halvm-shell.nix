{ pkgs ? import <nixpkgs> {} }:
  (import ./default.nix { inherit pkgs; }).hello-halvm.env
