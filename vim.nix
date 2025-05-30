{
  pkgs,
  lib,
  ...
}: let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins:
    with plugins; [
      lua
      cpp
      c
      cmake
      nix
      python
      rust
      bash
      fish
      latex
      javascript
      java
      kotlin
      html
      xml
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
      dockerfile
      commonlisp
      helm
    ]);
  vimPlugins = with pkgs.vimPlugins; [
    firenvim
    lazy-nvim
    oil-nvim
    nvim-tree-lua
    telescope-nvim
    telescope-live-grep-args-nvim
    vim-rhubarb
    copilot-vim
    avante-nvim
    comment-nvim
    conform-nvim
    nvim-lint
    zen-mode-nvim
    twilight-nvim
    nvim-highlight-colors
    gitsigns-nvim
    vim-fugitive
    flash-nvim
    # (pkgs.callPackage ./derivations/sqlite-lua.nix {}) # sqlite-lua but newer to be compatible with bookmarks-nvim below
    # (pkgs.callPackage ./derivations/bookmarks-nvim.nix {})
    (pkgs.callPackage ./derivations/match-visual-nvim.nix {})
    # for some reason old one has better startup time
    auto-session
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
    (import ./derivations/render-markdown-nvim.nix {inherit pkgs;})
    todo-comments-nvim
    treesitter
    nvim-treesitter-textobjects
  ];
in {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraLuaConfig = builtins.readFile ./dotfiles/nvim/extraLuaConfig.lua;
    extraLuaPackages = luaPkgs: with luaPkgs; [nvim-nio pathlib-nvim];
    plugins = vimPlugins;
    extraPackages = with pkgs; [
      sqlite
      wl-clipboard
      xclip
      stylua
      black
      ruff
      cmake-format
      eslint_d
      alejandra
      ktfmt
      # language servers
      lua-language-server
      nixd
      dockerfile-language-server-nodejs
      pyright
      kotlin-language-server
      yaml-language-server
      neocmakelsp
      nodePackages.bash-language-server
      fish-lsp
      vscode-langservers-extracted
      yaml-language-server
      jdt-language-server
      texlab
      rust-analyzer
      typescript-language-server
      terraform-ls
      #linters
      pylint
      yamllint
      #
      rustfmt
      (python3.withPackages (python-pkgs: [python-pkgs.mdformat-gfm]))
    ];
  };
  home.file.".config/nvim/lua/nix_paths.lua".text = let
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
        sqlite_clib_path = "${pkgs.sqlite.out}/lib/libsqlite3.so",
      	lazypath = "${pkgs.vimPlugins.lazy-nvim}",
      	load_treesitters = function ()
      	${load_treesitters_body}
      	end,
        -- https://github.com/NixOS/nixpkgs/issues/264141
        codelldb = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/.codelldb-wrapped_",
        lldb_dap = "${pkgs.lldb}/bin/lldb-dap"
      }
    '';

  /*
      TODO: find working url
  xdg.configFile = let
      nvim-spell-de-utf8-dictionary = builtins.fetchurl {
        url = "http://ftp.plvim.org/pub/vim/runtime/spell/de.utf-8.spl";
        sha256 = "sha256:1ld3hgv1kpdrl4fjc1wwxgk4v74k8lmbkpi1x7dnr19rldz11ivk";
      };
      # nvim-spell-de-utf8-suggestions = builtins.fetchurl {
      #   url = "http://ftp.vim.org/vim/runtime/spell/de.utf-8.sug";
      #   sha256 = "sha256:0j592ibsias7prm1r3dsz7la04ss5bmsba6l1kv9xn3353wyrl0k";
      # };
    in {
      # TODO: move to ./vim.nix
      "nvim/spell/de.utf-8.spl".source = nvim-spell-de-utf8-dictionary;
      # "nvim/spell/de.utf-8.sug".source = nvim-spell-de-utf8-suggestions;
    };
  */
}
