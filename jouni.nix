{pkgs, ...} @ inputs: {
  imports = [./home.nix ./hyprland.nix];
  home.username = "jouni";
  programs.fish.shellAbbrs = {
    neovide = "neovide --fork";
    n = "neovide --fork";
  };
  home.packages = with pkgs; [
    # on Ubuntu I'm using wezterm-nightly package (version 20241015-083151-9ddca7bd) because it has better startuptime
    wezterm
    ghostty
  ];
  programs.git = {
    userName = "JohnFinn";
    userEmail = "dz4tune@gmail.com";
  };
  programs.gnome-shell = {
    enable = true;
    extensions = [
      {package = pkgs.gnomeExtensions.caffeine;}
    ];
  };
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
    };
    defaultApplications = {
      "application/pdf" = ["org.gnome.Evince.desktop"];
    };
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
