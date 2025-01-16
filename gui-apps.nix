{pkgs, ...} @ inputs: {
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
  xdg.desktopEntries = {
    spotify-adblock = {
      name = "spotify-adblock";
      genericName = "music streamer";
      exec = "spotify-adblock";
      terminal = false;
    };
  };
  home.activation = {
    chrome-prefs = inputs.lib.hm.dag.entryAfter ["writeBoundary"] ''
      jq '.browser.custom_chrome_frame = true' < ~/.config/google-chrome/Default/Preferences | run ${pkgs.moreutils}/bin/sponge ~/.config/google-chrome/Default/Preferences
    '';
  };
}
