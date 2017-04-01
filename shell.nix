{ pkgs ? import <nixpkgs> {} }:
  (import ./default.nix { inherit pkgs; }).helloHaLVMTap.env
