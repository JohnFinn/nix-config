{pkgs, ...}: {
  home.packages = with pkgs; [
    anki
    kitty
    obsidian
    telegram-desktop
    discord
    swappy
    google-chrome
    spotify
    (pkgs.writeShellScriptBin "spotify-adblock" ''
      LD_PRELOAD=${pkgs.callPackage ./derivations/spotify-adblock.nix {}}/lib/libspotifyadblock.so spotify
    '')
    neovide
  ];
}
