{pkgs, ...}: {
  home.packages = with pkgs;
    [
      pkgs.wofi
      pkgs.blueberry
      pkgs.hyprpaper
      (ags.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [pkgs.libdbusmenu-gtk3 pkgs.libgtop];
      }))
      sassc
    ]
    ++ (with pkgs; [
      bun
      sassc
      pipewire
      networkmanager
      hyprshade
      hyprpicker
      swww
      imagemagick
      flatpak
      zenity
    ]);

  xdg.configFile = {
    "hypr/hyprpaper.conf".text = ''
      preload = ${pkgs.gnome-backgrounds}/share/backgrounds/gnome/pixels-d.jpg
      wallpaper = , ${pkgs.gnome-backgrounds}/share/backgrounds/gnome/pixels-d.jpg
    '';
    "ags".source = pkgs.fetchFromGitHub {
      owner = "JohnFinn";
      repo = "ags-dots";
      rev = "3d89fe533f967c85a4f8f782120053321243464d";
      sha256 = "sha256-Q58e0V2U/nVjyaVeVe2/Xz3DCfv9m1bUo4KxG/CGl8Y=";
    };
  };
}
