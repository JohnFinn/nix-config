{...}: {
  imports = [./home.nix];
  home.username = "sunnari";

  dconf.settings."org/gnome/desktop/input-sources".xkb-options = ["" "caps:swapescape"]; # TODO: replace with kanata
}
