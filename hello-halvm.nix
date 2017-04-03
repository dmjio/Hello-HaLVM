{ mkDerivation, base, stdenv, hans, file }:
mkDerivation {
  pname = "hello-halvm";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  dontStrip = true;
  isExecutable = true;
  executableHaskellDepends = [ base hans ];
  homepage = "hello-halvm.dmj.io";
  description = "A simple Hello World HaLVM web server";
  license = stdenv.lib.licenses.bsd3;
}
