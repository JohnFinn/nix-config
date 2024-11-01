{
  config,
  pkgs,
  pkgs_old,
  pkgs_firefox-addons,
  lib,
  ...
}: let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins:
    with plugins; [
      lua
      cpp
      c
      nix
      python
      rust
      bash
      fish
      latex
      javascript
      java
      html
      json
      yaml
      toml
      vimdoc
      tmux
      markdown
      todotxt
      terraform
      just
      thrift
      hcl
      (helm.overrideAttrs
        (oldAttrs: {
          src = pkgs.fetchFromGitHub {
            owner = "ngalaiko";
            repo = "tree-sitter-go-template";
            rev = "ca52fbfc98366c585b84f4cb3745df49f33cd140";
            hash = "sha256-ZWpzqKD3ceBzlsRjehXZgu+NZMbWyyK+/R1Ymg7DVkM=";
          };
        }))
    ]);
  vimPlugins = with pkgs.vimPlugins; [
    lazy-nvim
    oil-nvim
    telescope-nvim
    telescope-live-grep-args-nvim
    vim-rhubarb
    copilot-vim
    comment-nvim
    conform-nvim
    zen-mode-nvim
    twilight-nvim
    nvim-highlight-colors
    gitsigns-nvim
    vim-fugitive
    flash-nvim
    # for some reason old one has better startup time
    pkgs_old.vimPlugins.auto-session
    refactoring-nvim
    # completion
    nvim-cmp
    cmp-nvim-lsp
    luasnip
    cmp_luasnip
    cmp-path
    neodev-nvim
    nvim-lspconfig
    # debugging
    nvim-dap
    nvim-dap-python
    nvim-dap-ui
    # TODO: change loading icon
    fidget-nvim
    nvim-notify
    # -- theming
    mini-nvim
    noice-nvim
    nvim-web-devicons
    tokyonight-nvim
    vscode-nvim
    todo-comments-nvim
    treesitter
    nvim-treesitter-textobjects
  ];
in {
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    monolith
    todo-txt-cli
    pwgen
    hyperfine
    telegram-desktop
    chafa
    figlet
    cowsay
    bkt
    just
    kondo
    nixfmt-classic
    nh
    dust
    ncdu
    duf
    jq
    yq
    fd
    sd
    jless
    concurrently
    qpdf
    nodePackages.prettier
    tldr
    thefuck
    nix-output-monitor
    portal
    nvd
    htop
    btop
    dconf2nix
    git
    pkgs_old.lazygit
    lazydocker
    zsh
    fish
    tmux
    eza
    gdb
    nerdfonts
    pulsemixer
    alacritty
    neovide
    kitty
    # on Ubuntu I'm using wezterm-nightly package (version 20241015-083151-9ddca7bd) because it has better startuptime
    wezterm
    watchexec
    (import ./checkexec.nix {inherit pkgs;})
    jqp
    google-chrome
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
      (python-pkgs: [python-pkgs.ipython python-pkgs.pandas python-pkgs.matplotlib python-pkgs.debugpy]))
    anki
    obsidian
    discord
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
  services.espanso = {
    enable = true;
    configs.default.show_notifications = false;
  };
  services.syncthing = {
    enable = true;
  };

  xdg.configFile = let
    nvim-spell-de-utf8-dictionary = builtins.fetchurl {
      url = "http://ftp.vim.org/vim/runtime/spell/de.utf-8.spl";
      sha256 = "sha256:1ld3hgv1kpdrl4fjc1wwxgk4v74k8lmbkpi1x7dnr19rldz11ivk";
    };
    # nvim-spell-de-utf8-suggestions = builtins.fetchurl {
    #   url = "http://ftp.vim.org/vim/runtime/spell/de.utf-8.sug";
    #   sha256 = "sha256:0j592ibsias7prm1r3dsz7la04ss5bmsba6l1kv9xn3353wyrl0k";
    # };
  in {
    "nvim/spell/de.utf-8.spl".source = nvim-spell-de-utf8-dictionary;
    # "nvim/spell/de.utf-8.sug".source = nvim-spell-de-utf8-suggestions;
    "pulsemixer.cfg".source = ./dotfiles/pulsemixer.cfg;
    "mpv/mpv.conf".source = ./dotfiles/mpv.conf;
  };

  home.file = {
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".todo/config".source = ./dotfiles/todotxt-config;
    ".config/nvim/lua/nix_paths.lua".text = let
      load_treesitters_body = lib.strings.concatStrings (lib.strings.intersperse "\n"
        (
          lib.lists.forEach treesitter.dependencies
          (
            parser: let
              lang = lib.strings.removePrefix "vimplugin-treesitter-grammar-" parser.name;
            in
              /*
              lua
              */
              ''vim.treesitter.language.add("${lang}", {path = "${parser}/parser/${lang}.so"})''
          )
        ));
    in
      /*
      lua
      */
      ''
        return {
        	lazypath = "${pkgs.vimPlugins.lazy-nvim}",
        	load_treesitters = function ()
        	${load_treesitters_body}
        	end
        }
      '';
    ".config/wezterm/wezterm.lua".source = ./dotfiles/wezterm.lua;
    ".config/starship.toml".source = ./dotfiles/starship.toml;
    ".ideavimrc".source = ./dotfiles/nvim/ideavimrc;
    ".config/lazygit/config.yml".source = ./dotfiles/lazygit.yaml;
    ".config/espanso/match/base.yml".source = ./dotfiles/base.yml;
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
    ipython = "ipython --no-banner --no-confirm-exit";
    ipy = "ipython --no-banner --no-confirm-exit";
    python = "python -q";
    py = "python -q";
    # TODO: optimize chafa speed, maybe by caching thumbnails
    fzf = let
      preview =
        /*
        bash
        */
        "${pkgs.chafa}/bin/chafa -f iterm --view-size \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {} 2> /dev/null || ${pkgs.bat}/bin/bat --color=always {}";
    in "fzf --preview '${preview}' --bind ctrl-k:down,ctrl-l:up";
    cat = "${pkgs.bat}/bin/bat";
    ls = "${pkgs.eza}/bin/eza --icons --git -a --hyperlink --group-directories-first";
    lt = "${pkgs.eza}/bin/eza --icons --git -a --hyperlink --ignore-glob .git --tree";
    lt2 = "${pkgs.eza}/bin/eza --icons --git -a --hyperlink --ignore-glob .git --tree --level 2";
    gs = "git status";
    lg = "lazygit";
  };
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    bash = {
      enable = true;
      bashrcExtra =
        /*
        bash
        */
        ''
          source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh
        '';
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
      functions = {
        # NOTE: use upstream code once home-manager is updated https://github.com/nix-community/home-manager/pull/5449
        yazi.body =
          /*
          fish
          */
          ''
            set tmp (mktemp -t "yazi-cwd.XXXXX")
            command yazi $argv --cwd-file="$tmp"
            if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
                builtin cd -- "$cwd"
            end
            rm -f -- "$tmp"
          '';
      };
    };
    thefuck = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    atuin = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      settings = {
        style = "compact";
        inline_height = 20;
        show_preview = true;
      };
    };
    less = {
      enable = true;
      keys = ''
        k forw-line
        l back-line
      '';
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
    zathura = {
      enable = true;
      mappings = {
        "k" = "scroll down";
        "l" = "scroll up";
        "K" = "navigate next";
        "L" = "navigate previous";
      };
    };
    mpv = {
      enable = true;
      bindings = {
        "[" = "add speed -0.1";
        "]" = "add speed 0.1";
        "{" = "add speed -0.5";
        "}" = "add speed 0.5";
      };
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-esr; # enable installing of unsigned addons as xpinstall.signatures.required is not enough
      profiles = {
        personal = {
          isDefault = true;
          id = 0;
          settings = {
            "browser.shell.checkDefaultBrowser" = false;
            "extensions.pocket.enabled" = false;
            "extensions.autoDisableScopes" = 0;
            "browser.aboutwelcome.enabled" = false;
            "datareporting.policy.firstRunURL" = "";
            "xpinstall.signatures.required" = false;
          };
          search.force = true;
          search.engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@nix"];
            };
          };
          extensions = [
            pkgs_firefox-addons.dictionary-german
            pkgs_firefox-addons.ublock-origin
            pkgs_firefox-addons.sponsorblock
            pkgs_firefox-addons.istilldontcareaboutcookies
            pkgs_firefox-addons.videospeed
            pkgs_firefox-addons.vimium # TODO: remap hjkl
            (import ./firefox_addon_web_vim_remap.nix {inherit pkgs;})
          ];
        };
        work = {
          isDefault = false;
          id = 1;
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
    yazi = {
      enable = true;
      keymap.manager.prepend_keymap = [
        {
          on = ["l"];
          run = "arrow -1";
          desc = "Move cursor up";
        }
        {
          on = ["k"];
          run = "arrow 1";
          desc = "Move cursor down";
        }
        {
          on = ["j"];
          run = "leave";
          desc = "Go back to the parent directory";
        }
        {
          on = [";"];
          run = "enter";
          desc = "Enter the child directory";
        }
        {
          on = ["L"];
          run = "seek -5";
          desc = "Seek up 5 units in the preview";
        }
        {
          on = ["K"];
          run = "seek 5";
          desc = "Seek down 5 units in the preview";
        }
        {
          on = ["i"];
          run = ''
            shell '${pkgs.ripdrag}/bin/ripdrag "$@"' --confirm
          '';
        }
      ];
      theme.icon.prepend_dirs = [
        {
          name = "Sync";
          text = "󰴋";
        }
      ];
      theme.icon.files = [
        {
          name = ".ideavimrc";
          text = " ";
        }
      ];
    };
    neovim = {
      enable = true;
      vimAlias = true;
      extraLuaConfig = builtins.readFile ./dotfiles/nvim/extraLuaConfig.lua;

      extraLuaPackages = luaPkgs: with luaPkgs; [nvim-nio pathlib-nvim];
      plugins = vimPlugins;
      extraPackages = with pkgs; [
        wl-clipboard
        stylua
        black
        alejandra
        lua-language-server
        nixd
        pyright
        nodePackages.bash-language-server
        vscode-langservers-extracted
        yaml-language-server
        jdt-language-server
        texlab
        rust-analyzer
        typescript-language-server
        rustfmt
        (python3.withPackages (python-pkgs: [python-pkgs.mdformat-gfm]))
      ];
    };
    tmux = {
      enable = true;
      mouse = true;
      prefix = "C-a";
      baseIndex = 1;
      terminal = "screen-256color";
      extraConfig =
        /*
        tmux
        */
        ''
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
          extraConfig =
            /*
            tmux
            */
            ''
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
    k9s = {
      enable = true;
      settings.k9s.ui = {
        skin = "vscode";
        enableMouse = true;
      };
      skins = {
        vscode = {
          k9s = {
            body.bgColor = "default";
            frame.title.bgColor = "default";
            views.table.bgColor = "default";
            views.table.header.bgColor = "default";
            views.logs.bgColor = "default";
          };
        };
      };
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
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "wezterm";
      name = "terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>b";
      command = "${config.programs.firefox.finalPackage}/bin/firefox-esr";
      name = "browser";
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
    "org/gnome/desktop/sound".allow-volume-above-100-percent = true;
  };
}
