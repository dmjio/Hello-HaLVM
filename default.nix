{ pkgs ? import <nixpkgs> {} }:
let
  halvmPkgs = pkgs.haskell.packages.integer-simple.ghcHaLVM240.override {
    overrides = self: super: with pkgs.haskell.lib; {
      mkDerivation = args: super.mkDerivation (args // { hardeningDisable = ["stackprotector"]; });
      cryptonite = disableCabalFlag super.cryptonite "integer-gmp";
    };
  };
  ghc802Pkgs = pkgs.haskellPackages.override {
    overrides = self: super: with pkgs.haskell.lib; {
      heaps = doJailbreak super.heaps;
    };
  };
  hello-halvm = halvmPkgs.callPackage ./hello-halvm.nix {};
  helloHaLVMTap = ghc802Pkgs.callPackage ./hello-halvm.nix {};
  setupTap = pkgs.writeScriptBin "setupTap" ''
    # edit this script at your leisure
    set -ev
    # make sure you defined a bridge here, by default Xen uses `br0`
    # but the NixOS xen bridge default config has some issues
    # so you might want to make your own bridge
    bridge=br0 
    # Makes a tap device, if not already configured
    sudo ip tuntap add dev tap1 mode tap user $USER
    sudo ip link set dev tap1 master $bridge
    sudo ip link set dev tap1 up
  '';
  buildEnvPkgs = {
    inherit hello-halvm helloHaLVMTap;
  };
in pkgs.runCommand "hello-halvm" buildEnvPkgs '' 
     mkdir -p $out/bin
     cp ${hello-halvm}/bin/hello-halvm $out/bin
     cp ${setupTap}/bin/setupTap $out/bin
     cp ${helloHaLVMTap}/bin/hello-halvm $out/bin/hello-halvm-tap
   ''
