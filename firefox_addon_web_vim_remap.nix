{pkgs}: let
  addonId = "hackce@nanigashi.stackoverflow";
in
  pkgs.stdenv.mkDerivation {
    name = "hackce-0.1";

    src = pkgs.fetchFromGitHub {
      owner = "JohnFinn";
      repo = "web_vim_remap";
      rev = "main";
      sha256 = "sha256-H4SIRSsXGZgArLRf0Ao12aN6ZUaIdGQ2Majo1xG26Ck=";
    };

    preferLocalBuild = true;
    allowSubstitutes = true;

    passthru = {inherit addonId;};

    nativeBuildInputs = [pkgs.web-ext];

    buildCommand = ''
      web-ext build --source-dir "$src"
      dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
      mkdir -p "$dst"
      install -v -m644 "web-ext-artifacts/hackce-0.1.zip" "$dst/${addonId}.xpi"
    '';
  }
