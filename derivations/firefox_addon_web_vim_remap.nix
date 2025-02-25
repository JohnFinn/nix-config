# copy-pasted and modified from https://github.com/nix-community/nur-combined/blob/87ffa62e85cd000fdd2cb0e5ef9d5a9cf3c2eef4/repos/rycee/pkgs/firefox-addons/default.nix#L5-L25
{
  stdenv,
  fetchFromGitHub,
  web-ext,
}: let
  addonId = "hackce@nanigashi.stackoverflow";
in
  stdenv.mkDerivation {
    name = "hackce-0.1";

    src = fetchFromGitHub {
      owner = "JohnFinn";
      repo = "web_vim_remap";
      rev = "a91b81f1a1340a9d6b2f171c72ff933a9c07c501";
      sha256 = "sha256-Pio6UlG1egWjHhNlDEPOzIiMTbp216JgcKPRpt83QwQ=";
    };

    preferLocalBuild = true;
    allowSubstitutes = true;

    passthru = {inherit addonId;};

    nativeBuildInputs = [web-ext];

    buildCommand = ''
      web-ext build --source-dir "$src"
      dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
      mkdir -p "$dst"
      install -v -m644 "web-ext-artifacts/hackce-0.1.zip" "$dst/${addonId}.xpi"
    '';
  }
