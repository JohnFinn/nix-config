{pkgs, ...} @ inputs: {
  imports = [./home.nix];
  home.username = "sunnari";

  programs.fish.shellAbbrs = {
    neovide = "nixGLIntel neovide --fork";
    n = "nixGLIntel neovide --fork";
    anki = "nixGLIntel anki";
    sudo = "sudo --preserve-env=PATH env";
  };

  home.packages = [
    pkgs.nixgl.nixGLIntel
    inputs.ghostty
    pkgs.git-lfs
  ];

  services.espanso = {enable = true;};
  dconf.settings = {
    "org/gnome/desktop/input-sources".xkb-options = ["" "caps:swapescape"]; # TODO: replace with kanata

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      # command = ''wezterm --config default_prog={\'${pkgs.fish}/bin/fish\'}''; # making sure fish from nix store is used on non-nixos systems
      command = ''${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.ghostty}/bin/ghostty --command=${pkgs.fish}/bin/fish'';
      name = "terminal";
    };
  };

  home.file.".local/share/applications/telegram.desktop".text = ''
    [Desktop Entry]
    Name=Telegram Desktop
    Comment=Official desktop version of Telegram messaging app
    Exec=${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.telegram-desktop}/bin/telegram-desktop -- %u
    Icon=${pkgs.telegram-desktop}/share/icons/hicolor/512x512/apps/telegram.png
    Terminal=false
    StartupWMClass=TelegramDesktop
    Type=Application
    Categories=Chat;Network;InstantMessaging;Qt;
    MimeType=x-scheme-handler/tg;
    Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
    Actions=quit;
    DBusActivatable=true
    SingleMainWindow=true
    X-GNOME-UsesNotifications=true
    X-GNOME-SingleWindow=true

    [Desktop Action quit]
    Exec=telegram-desktop -quit
    Name=Quit Telegram
    Icon=application-exit
  '';

  home.file.".local/share/applications/anki.desktop".text = ''
    [Desktop Entry]
    Name=Anki
    Exec=${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.anki}/bin/anki %f
    Icon=${pkgs.anki}/share/pixmaps/anki.png
    Terminal=false
    Type=Application
    Version=1.0
    MimeType=application/x-apkg;application/x-anki;application/x-ankiaddon;
  '';

  home.file.".local/share/applications/spotify.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Spotify
    GenericName=Music Player
    Exec=${pkgs.spotify}/bin/spotify %U
    Icon=${pkgs.spotify}/share/spotify/icons/spotify-linux-128.png
    Terminal=false
    MimeType=x-scheme-handler/spotify;
    Categories=Audio;Music;Player;AudioVideo;
    StartupWMClass=spotify
  '';
  # NOTE: impure invocation of systemctl
  # FIXME: fails to start after reboot
  home.activation = {
    startEspanso = inputs.lib.hm.dag.entryAfter ["writeBoundary"] ''
      run /usr/bin/systemctl start --user espanso.service
    '';
  };
}
