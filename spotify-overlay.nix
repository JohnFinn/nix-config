# copy-paste from https://github.com/oskardotglobal/.dotfiles/blob/nix/overlays/spotx.nix
final: prev: let
  spotx = prev.fetchFromGitHub {
    owner = "SpotX-Official";
    repo = "SpotX-Bash";
    rev = "2aaa003b4903d74d076dc85e6297a0caf93aea36";
    sha256 = "sha256-IHXKJ3a5cGhpmkQ2crSq+rCpjocbDaSvKw5icP19lEw=";
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
