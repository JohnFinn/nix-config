# copy-paste from https://github.com/oskardotglobal/.dotfiles/blob/nix/overlays/spotx.nix
final: prev: let
  spotx = prev.fetchFromGitHub {
    owner = "SpotX-Official";
    repo = "SpotX-Bash";
    rev = "63b31200ff28feae474a4898d1e2fd7de04e2969";
    sha256 = "sha256-3Fvizc52/AUnsRX5I/y1Yk+O7FOoI0cJPDcn0vxzq4E=";
  };
  spotx_sh = "${spotx}/spotx.sh";
in {
  spotify = prev.spotify.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ (with prev; [util-linux perl unzip zip curl]);

    unpackPhase =
      builtins.replaceStrings
      ["runHook postUnpack"]
      [
        ''
          patchShebangs --build ${spotx_sh}
          runHook postUnpack
        ''
      ]
      old.unpackPhase;

    installPhase =
      builtins.replaceStrings
      ["runHook postInstall"]
      [
        ''
          bash ${spotx_sh} -f -P "$out/share/spotify"
          runHook postInstall
        ''
      ]
      old.installPhase;
  });
}
