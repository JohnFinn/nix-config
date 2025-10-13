# copy-paste from https://github.com/oskardotglobal/.dotfiles/blob/nix/overlays/spotx.nix
final: prev: let
  spotx = prev.fetchFromGitHub {
    owner = "SpotX-Official";
    repo = "SpotX-Bash";
    rev = "12cfe5dcec1d82cb613d8aa8dd60f4cd181dfb06";
    sha256 = "sha256-GPy9/fJhcx1XPS6WRt4yVQQrEt/YQCh2cDzQxb1nvfg=";
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
