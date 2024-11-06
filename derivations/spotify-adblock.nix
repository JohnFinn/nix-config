{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  name = "spotify-adblock";
  src = fetchFromGitHub {
    owner = "abba23";
    repo = "spotify-adblock";
    rev = "7391666109c8f9d0ccc8254dc0ff7e28139c663b";
    sha256 = "sha256-OjbJAn/QWXxaARyiKDBLdxCRscC+ZdaCRoBhINkmfHM=";
  };
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };
}
