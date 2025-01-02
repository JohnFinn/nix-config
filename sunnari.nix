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
    pkgs.nixgl.nixGLIntel # TODO: investigate why packages are duplicated resulting in ~1GB of extra disk space usage
    inputs.ghostty
  ];
  dconf.settings = {
    "org/gnome/desktop/input-sources".xkb-options = ["" "caps:swapescape"]; # TODO: replace with kanata

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = ''wezterm --config default_prog={\'${pkgs.fish}/bin/fish\'}''; # making sure fish from nix store is used on non-nixos systems
      name = "terminal";
    };
  };

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
}
