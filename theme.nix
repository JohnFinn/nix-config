{pkgs, ...}: {
  home.packages = [pkgs.yaru-theme];
  dconf.settings = {
    "org/gnome/desktop/interface".gtk-theme = "Yaru-prussiangreen-dark";
    "org/gnome/desktop/interface".cursor-theme = "Yaru";
    "org/gnome/desktop/sound".theme-name = "Yaru"; # TODO: change charging sound to adwaita
  };
}
