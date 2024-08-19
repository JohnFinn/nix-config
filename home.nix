{
  config,
  pkgs,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jouni";
  home.homeDirectory = "/home/jouni";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      google-chrome = prev.google-chrome.overrideAttrs (oldAttrs: {
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            substituteInPlace $out/share/applications/google-chrome.desktop \
              --replace "/bin/google-chrome-stable %U" "/bin/google-chrome-stable --load-extension=${./meetup-auto-login} %U"
          '';
      });
    })
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    hyperfine
    telegram-desktop
    yazi
    nixfmt-classic
    nh
    dust
    ncdu
    duf
    nix-output-monitor
    portal
    nvd
    htop
    btop
    dconf2nix
    git
    lazygit
    zsh
    fish
    tmux
    eza
    nerdfonts
    pulsemixer
    alacritty
    kitty
    wezterm
    watchexec
    jqp
    google-chrome
    lunarvim
    starship
    zoxide
    direnv
    fzf
    entr
    clang
    clang-tools
    ripgrep
    swappy
    (python3.withPackages
      (python-pkgs: [python-pkgs.ipython python-pkgs.pandas]))
    zathura
    anki
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # NOTE: espanso won't start automatically. Use `espanso service start --unmanaged` to start it
  # FIXME: make it work on wayland
  services.espanso = {enable = true;};

  home.file = {
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/lvim/config.lua".source = ./lvim-config.lua;
    ".config/starship.toml".source = ./starship.toml;
    ".ideavimrc".source = ./nvim/ideavimrc;
    ".config/lazygit/config.yml".source = ./lazygit.yaml;
    ".config/fish/functions/fish_user_key_bindings.fish".source =
      ./fish_user_key_bindings.fish;
    ".config/espanso/match/base.yml".source = ./base.yml;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jouni/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {EDITOR = "vim";};
  home.shellAliases = {
    ipython = "ipython --no-banner";
    ipy = "ipython --no-banner";
    python = "python -q";
    py = "python -q";
    fzf = "fzf --preview '${pkgs.bat}/bin/bat --color=always {}'";
    cat = "${pkgs.bat}/bin/bat";
    ls = "${pkgs.eza}/bin/eza -l --icons --git -a --hyperlink";
    lt = "${pkgs.eza}/bin/eza -l --icons --git -a --hyperlink --ignore-glob .git --tree";
    lt2 = "${pkgs.eza}/bin/eza -l --icons --git -a --hyperlink --ignore-glob .git --tree --level 2";
  };
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    bash = {enable = true;};
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
    };
    atuin = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      settings = {
        style = "compact";
        inline_height = 20;
      };
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      options = ["--cmd" "cd"];
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    wezterm = {
      enable = true;
      extraConfig =
        /*
        lua
        */
        ''
          return {
          	hide_mouse_cursor_when_typing = false,
          	color_scheme = 'Tokyo Night',
              font = wezterm.font('JetBrains Mono Nerd Font'),
          };
        '';
    };
    alacritty = {
      enable = true;
      # settings.window.decorations = "None";
      settings.env.TERM = "screen-256color";
      settings.colors = {
        "bright" = {
          "black" = "#414868";
          "blue" = "#7aa2f7";
          "cyan" = "#7dcfff";
          "green" = "#9ece6a";
          "magenta" = "#bb9af7";
          "red" = "#f7768e";
          "white" = "#c0caf5";
          "yellow" = "#e0af68";
        };
        "indexed_colors" = [
          {
            "color" = "#ff9e64";
            "index" = 16;
          }
          {
            "color" = "#db4b4b";
            "index" = 17;
          }
        ];
        "normal" = {
          "black" = "#15161e";
          "blue" = "#7aa2f7";
          "cyan" = "#7dcfff";
          "green" = "#9ece6a";
          "magenta" = "#bb9af7";
          "red" = "#f7768e";
          "white" = "#a9b1d6";
          "yellow" = "#e0af68";
        };
        "primary" = {
          "background" = "#1a1b26";
          "foreground" = "#c0caf5";
        };
      };
    };
    git = {
      enable = true;
      userName = "JohnFinn";
      userEmail = "dz4tune@gmail.com";
      extraConfig = {
        core = {editor = "nvim";};
        init.defaultBranch = "main";
      };
      delta.enable = true;
    };
    neovim = {
      enable = true;
      vimAlias = true;
      extraConfig = builtins.readFile ./nvim/vimrc;
      extraLuaConfig = builtins.readFile ./nvim/extraLuaConfig.lua;
      plugins = with pkgs.vimPlugins; [
        telescope-nvim
        telescope-live-grep-args-nvim
        copilot-vim
        comment-nvim
        conform-nvim
        zen-mode-nvim
        twilight-nvim
        gitsigns-nvim
        # completion
        nvim-cmp
        cmp-nvim-lsp
        luasnip
        cmp_luasnip
        cmp-path
        neodev-nvim
        # --
        nvim-treesitter
        nvim-treesitter-parsers.lua
        nvim-treesitter-parsers.cpp
        nvim-treesitter-parsers.c
        nvim-treesitter-parsers.nix
        nvim-treesitter-parsers.python
        nvim-treesitter-parsers.rust
        nvim-treesitter-parsers.bash
        nvim-treesitter-parsers.fish
        nvim-lspconfig
        # TODO: change loading icon
        fidget-nvim
        nvim-notify
        # -- theming
        mini-nvim
        noice-nvim
        nvim-web-devicons
        tokyonight-nvim
        todo-comments-nvim
        (pkgs.vimUtils.buildVimPlugin {
          name = "context-vim";
          src = pkgs.fetchFromGitHub {
            owner = "doums";
            repo = "darcula";
            rev = "faf8dbab27bee0f27e4f1c3ca7e9695af9b1242b";
            sha256 = "sha256-Gn+lmlYxSIr91Bg3fth2GAQou2Nd1UjrLkIFbBYlmF8=";
          };
        })
      ];
      extraPackages = with pkgs; [
        wl-clipboard
        stylua
        black
        alejandra
        lua-language-server
        nil
        nodePackages.pyright
        texlab
        rust-analyzer
        rustfmt
      ];
    };
    tmux = {
      enable = true;
      mouse = true;
      prefix = "C-a";
      baseIndex = 1;
      terminal = "screen-256color";
      extraConfig = ''
        unbind r
        bind r source-file ~/.config/tmux/tmux.conf
        set-option -g status-position top
        set -s escape-time 0
        set -ga terminal-overrides ',*256col*:Tc'
      '';
      tmuxinator.enable = true;
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_right_separator " "
            set -g @catppuccin_window_middle_separator " █"
            set -g @catppuccin_window_number_position "right"

            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"

            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W"

            set -g @catppuccin_status_modules_right "directory user host session"
            set -g @catppuccin_status_left_separator  " "
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"

            set -g @catppuccin_directory_text "#{pane_current_path}"
          '';
        }
      ];
    };
  };

  fonts.fontconfig.enable = true;

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/input-sources" = {
      mru-sources = [(mkTuple ["xkb" "us"])];
      sources = [(mkTuple ["xkb" "us"]) (mkTuple ["xkb" "ru"])];
      xkb-options = ["" "caps:swapescape"];
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      toggle-fullscreen = ["<Super>f"];
    };
    "org/gnome/desktop/wm/preferences" = {focus-mode = "sloppy";};
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "wezterm start fish";
      name = "terminal";
    };
    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      font = "0xProto Nerd Font 12";
      use-system-font = false;
      use-custom-command = true;
      custom-command = "fish";
      # background-color = "rgb(23,20,33)";
      background-color = "rgb(26, 27, 38)"; # from tokyonight theme
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
  };
}
