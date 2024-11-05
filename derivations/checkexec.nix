{pkgs}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "checkexec";
  version = "0.2.0";
  src = pkgs.fetchFromGitHub {
    owner = "kurtbuilds";
    repo = "checkexec";
    rev = "v0.2.0";
    sha256 = "sha256-osLtyVXR4rASwRJmbu6jD8o3h12l/Ty4O8/XTl5UzB4";
  };
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };
}
