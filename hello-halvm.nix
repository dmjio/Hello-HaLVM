{ mkDerivation, base, stdenv, hans }:
mkDerivation {
  pname = "hello-halvm";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base hans ];
  homepage = "hello-halvm.dmj.io";
  description = "A simple Hello World HaLVM web server";
  license = stdenv.lib.licenses.bsd3;
}
