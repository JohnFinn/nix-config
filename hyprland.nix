{pkgs, ...}: {
  home.packages = with pkgs; [
    pkgs.wofi
    pkgs.blueberry
    pkgs.hyprpaper
  ];

  xdg.configFile = {
    "hypr/hyprpaper.conf".text = ''
      preload = ${pkgs.gnome-backgrounds}/share/backgrounds/gnome/pixels-d.jpg
      wallpaper = , ${pkgs.gnome-backgrounds}/share/backgrounds/gnome/pixels-d.jpg
    '';
  };
}
