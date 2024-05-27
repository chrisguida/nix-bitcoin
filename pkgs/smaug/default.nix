{ lib, stdenv, fetchFromGitHub, openssl, pkg-config }:

stdenv.mkDerivation rec {
  pname = "smaug";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "chrisguida";
    repo = "smaug";
#    rev = "v${version}";
    rev = "d011f9b0a21a9b614c571c648724e5b7e51b8807";
    hash = "";
  };

  nativeBuildInputs = [
    openssl
    pkg-config
  ];

#  buildInputs = with pkgs; [ pkg-config openssl clightning ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Reports sends and receives from any external on-chain wallet to CLN's bookkeeper plugin";
    homepage = "https://github.com/chrisguida/smaug";
    changelog = "https://github.com/chrisguida/smaug";
    license = licenses.mit;
    maintainers = with maintainers; [ chrisguida ];
    platforms = platforms.linux;
  };
}
