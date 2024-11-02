{
  pkgs,
  pkgs_old,
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
  programs.neovim = {
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
      	lazypath = "${pkgs.vimPlugins.lazy-nvim}",
      	load_treesitters = function ()
      	${load_treesitters_body}
      	end
      }
    '';

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
    # TODO: move to ./vim.nix
    "nvim/spell/de.utf-8.spl".source = nvim-spell-de-utf8-dictionary;
    # "nvim/spell/de.utf-8.sug".source = nvim-spell-de-utf8-suggestions;
  };
}
