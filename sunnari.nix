{...}: {
  imports = [./home.nix];
  home.username = "sunnari";

  programs.fish.shellAbbrs = {
    neovide = "nixGLIntel neovide";
  };
  dconf.settings."org/gnome/desktop/input-sources".xkb-options = ["" "caps:swapescape"]; # TODO: replace with kanata
}
