{pkgs, ...}: {
  imports = [./home.nix];
  home.username = "jouni";
  programs.fish.shellAbbrs = {
    neovide = "neovide --fork";
    n = "neovide --fork";
  };
  home.packages = with pkgs; [
    # on Ubuntu I'm using wezterm-nightly package (version 20241015-083151-9ddca7bd) because it has better startuptime
    wezterm
  ];
  dconf.settings."org/gnome/desktop/input-sources".xkb-options = [""];
}
