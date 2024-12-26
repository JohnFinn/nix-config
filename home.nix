{
  config,
  pkgs,
  pkgs_firefox-addons,
  lib,
  ...
}: {
  imports = [
    ./vim.nix
    ./theme.nix
    ./gui-apps.nix
    ({pkgs, ...}: {
      home.packages = [pkgs.easyeffects];
      xdg.configFile = {
        "easyeffects/output".source = pkgs.fetchFromGitHub {
          owner = "Digitalone1";
          repo = "EasyEffects-Presets";
          rev = "32d0f416e7867ccffdab16c7fe396f2522d04b2e";
          sha256 = "sha256-U9SSyHOOs8GsV6GBEqAqlBAuYONeh/4nkK8HurkEfWk=";
        };
      };
    })
  ];

  home.homeDirectory = "/home/${config.home.username}";

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
    yt-dlp
    ags
    opentofu
    dotenvx
    monolith
    ffmpeg
    ripdrag
    todo-txt-cli
    expect
    pwgen
    hyperfine
    chafa
    figlet
    cowsay
    lolcat
    fortune
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
    (pkgs.callPackage ./derivations/otree.nix {})
    (pkgs.callPackage ./derivations/mdtohtml.nix {})
    concurrently
    qpdf
    nodePackages.prettier
    tldr
    nix-output-monitor
    portal
    nvd
    htop
    btop
    dconf2nix
    lazygit
    lazydocker
    zsh
    eza
    gdb
    nerdfonts
    pulsemixer
    watchexec
    (pkgs.callPackage ./derivations/checkexec.nix {})
    jqp
    wl-clipboard
    entr
    clang
    clang-tools
    hadolint
    ripgrep
    (python3.withPackages
      (python-pkgs: [python-pkgs.ipython python-pkgs.pandas python-pkgs.matplotlib python-pkgs.debugpy python-pkgs.tqdm]))
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

  xdg.configFile = {
    "pulsemixer.cfg".source = ./dotfiles/pulsemixer.cfg;
    "mpv/mpv.conf".source = ./dotfiles/mpv.conf;
    "otree.toml".source = ./dotfiles/otree.toml;
  };

  home.file = {
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".todo/config".source = ./dotfiles/todotxt-config;
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
    python = "python -q";
    # TODO: optimize chafa speed, maybe by caching thumbnails
    fzf = let
      preview =
        /*
        bash
        */
        "${pkgs.chafa}/bin/chafa -f iterm --view-size \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {} 2> /dev/null || ${pkgs.bat}/bin/bat --color=always {}";
      respect_gitignore_find = "${pkgs.fd}/bin/fd --type f";
    in "FZF_DEFAULT_COMMAND='${respect_gitignore_find}' ${config.programs.fzf.package}/bin/fzf --preview '${preview}' --bind ctrl-k:down,ctrl-l:up";
    cat = "${pkgs.bat}/bin/bat";
    ls = "${pkgs.eza}/bin/eza --icons --git -a --hyperlink --group-directories-first";
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
      interactiveShellInit =
        /*
        fish
        */
        ''
          set fish_greeting
          just --completions fish | source
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
        fish_user_key_bindings.body =
          /*
          fish
          */
          ''
            bind --preset \ea 'fish_commandline_prepend "bkt --ttl 1h --"'
          '';
      };
      shellAbbrs = {
        lg = "lazygit";
        gs = "git status";
        ga = "git add";
        gp = "git pull";
        gco = "git checkout";
        ipy = "ipython";
        py = "python";
        ta = "todo.sh -t add";
        j = "just";
        we = "watchexec -r --clear --";
        "...." = "../..";
        "......" = "../../..";
        nhm = {
          position = "anywhere";
          expansion = "nh home switch ~/.config/home-manager";
        };
        nos = "nh os switch ~/.config/home-manager -H default";
        lt = "ls --ignore-glob .git --tree";
        lt2 = "ls --ignore-glob .git --tree --level 2";
        kux = "kubectl exec -it";
        ku = "kubectl";
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
        network_timeout = 5;
        network_connect_timeout = 5;
        local_timeout = 2;
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
      package =
        pkgs.fzf.overrideAttrs
        (oldAttrs: {
          version = "3b0c86e4013abb66f36108aedad4ef81fe2a06e2";
          src = pkgs.fetchFromGitHub {
            owner = "junegunn";
            repo = "fzf";
            rev = "3b0c86e4013abb66f36108aedad4ef81fe2a06e2";
            hash = "sha256-jmpdGbLSMpdj+kpdyVbtBDTMhjg1MI218CXe34m7fAg=";
          };
          vendorHash = "sha256-4VAAka9FvKuoDZ1E1v9Es3r00GZeG8Jp4pJONYpB/t8=";
        });
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
            (pkgs.callPackage ./derivations/firefox_addon_web_vim_remap.nix {})
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
        core = {
          editor = "nvim";
          excludesFile = "${pkgs.writeText ".gitignore" ''
            .direnv
            .cache/clangd/index
          ''}";
        };
        init.defaultBranch = "main";
      };
      delta.enable = true;
      # difftastic.enable = true;
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
            shell '${pkgs.ripdrag}/bin/ripdrag --all --no-click --and-exit "$@"' --confirm
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
    "org/gnome/mutter".dynamic-workspaces = true;
    "org/gnome/desktop/input-sources" = {
      mru-sources = [(mkTuple ["xkb" "us"])];
      sources = [(mkTuple ["xkb" "us"]) (mkTuple ["xkb" "ru"])];
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
      screensaver = ["<Super>l"];
    };
    "org/gnome/desktop/session" = {idle-delay = mkUint32 900;};
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = ''wezterm --config default_prog={\'${pkgs.fish}/bin/fish\'}''; # making sure fish from nix store is used on non-nixos systems
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
    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled = false;
      power-saver-profile-on-low-battery = true;
      sleep-inactive-ac-timeout = 3600;
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-battery-timeout = 900;
      sleep-inactive-battery-type = "suspend";
    };
  };
}
