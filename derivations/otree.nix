{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "otree";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "fioncat";
    repo = "otree";
    rev = "v0.3.0";
    sha256 = "sha256-WvoiTu6erNI5Cb9PSoHgL6+coIGWLe46pJVXBZHOLTE=";
  };
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };
}
