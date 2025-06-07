{pkgs, ...} @ inputs: {
  imports = [./json-field.nix];
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
  programs.brave = {
    enable = true;
    extensions = [
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
    ];
  };
  xdg.desktopEntries = {
    spotify-adblock = {
      name = "spotify-adblock";
      genericName = "music streamer";
      exec = "spotify-adblock";
      terminal = false;
    };
  };
  jsonField = {
    "~/.config/BraveSoftware/Brave-Browser/Default/Preferences" = {
      key = ".extensions.theme.system_theme";
      value = "1";
    };
    "~/.config/google-chrome/Default/Preferences" = {
      key = ".browser.custom_chrome_frame";
      value = "true";
    };
  };
}
