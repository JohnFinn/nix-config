# copy-paste from https://github.com/oskardotglobal/.dotfiles/blob/nix/default.nix
final: prev: {
  spotify = prev.spotify.overrideAttrs (old: {
    srcs = [
      old.src
      (prev.fetchurl {
        url = "https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/9b8e3a6c443f5bde5803505105a569fac8510668/spotx.sh";
        hash = "sha256-vry/wB5mcQUNeUUwwipzGwsZhxOJYJkc2w5z9vmcRdE=";
      })
    ];

    nativeBuildInputs = old.nativeBuildInputs ++ (with prev; [util-linux perl unzip zip curl]);

    unpackPhase =
      builtins.replaceStrings
      [
        "unsquashfs \"$src\" '/usr/share/spotify' '/usr/bin/spotify' '/meta/snap.yaml'"
      ]
      [
        ''
          unsquashfs "$(echo $srcs | awk '{print $1}')" '/usr/share/spotify' '/usr/bin/spotify' '/meta/snap.yaml'
          patchShebangs --build "$(echo $srcs | awk '{print $2}')"
        ''
      ]
      old.unpackPhase;

    installPhase =
      builtins.replaceStrings
      ["runHook postInstall"]
      [
        ''
          bash "$(echo $srcs | awk '{print $2}')" -f -P "$out/share/spotify"
          runHook postInstall
        ''
      ]
      old.installPhase;
  });
}
