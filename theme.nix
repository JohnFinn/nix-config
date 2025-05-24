{pkgs, ...}: {
  home.packages = [pkgs.yaru-theme];
  dconf.settings = {
    "org/gnome/desktop/interface".gtk-theme = "Yaru-prussiangreen-dark";
    "org/gnome/desktop/interface".cursor-theme = "Yaru";
    "org/gnome/desktop/sound".theme-name = "mysoundtheme";
    "org/gnome/desktop/background".picture-uri-dark = let
      bg = pkgs.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "GNOME";
        repo = "gnome-backgrounds";
        rev = "gnome-46";
        sha256 = "sha256-pWyh/oUSTfHERYev3TH/xlkRNY+Z5xrsuHutafd01m4=";
      };
    in "${bg}/backgrounds/pixels-d.jpg";
  };
  home.file = {
    ".local/share/sounds/mysoundtheme/index.theme".text = ''
      [Sound Theme]
      Name=mysoundteme
      Directories=stereo

      [stereo]
      OutputProfile=stereo
    '';
    ".local/share/sounds/mysoundtheme/stereo/audio-volume-change.oga".source = pkgs.stdenvNoCC.mkDerivation {
      name = "mysoundtheme";
      installPhase = ''
        cp ${pkgs.yaru-theme}/share/sounds/Yaru/stereo/audio-volume-change.oga $out
      '';
      phases = ["installPhase" "fixupPhase"];
    };
  };
}
