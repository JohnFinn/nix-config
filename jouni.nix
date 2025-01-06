{pkgs, ...} @ inputs: {
  imports = [./home.nix];
  home.username = "jouni";
  programs.fish.shellAbbrs = {
    neovide = "neovide --fork";
    n = "neovide --fork";
  };
  home.packages = with pkgs; [
    # on Ubuntu I'm using wezterm-nightly package (version 20241015-083151-9ddca7bd) because it has better startuptime
    wezterm
    inputs.ghostty
  ];
  programs.git = {
    userName = "JohnFinn";
    userEmail = "dz4tune@gmail.com";
  };
  dconf.settings = {
    "org/gnome/desktop/input-sources".xkb-options = [""];

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = ''ghostty --command=${pkgs.fish}/bin/fish'';
      name = "terminal";
    };
  };
}
