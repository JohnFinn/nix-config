{...}: {
  imports = [./home.nix];
  home.username = "sunnari";

  programs.fish.shellAbbrs = {
    neovide = "nixGLIntel neovide";
    anki = "nixGLIntel anki";
    sudo = "sudo --preserve-env=PATH env";
  };
  dconf.settings."org/gnome/desktop/input-sources".xkb-options = ["" "caps:swapescape"]; # TODO: replace with kanata
}
