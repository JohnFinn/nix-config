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
  dconf.settings."org/gnome/desktop/input-sources".xkb-options = ["" "caps:swapescape"]; # TODO: replace with kanata
}
