{pkgs, ...}: {
  home.packages = [pkgs.yaru-theme];
  dconf.settings = {
    "org/gnome/desktop/interface".gtk-theme = "Yaru-dark";
    "org/gnome/desktop/interface".cursor-theme = "Yaru";
    "org/gnome/desktop/sound".theme-name = "Yaru";
  };
}
