noremap ; l
noremap l k
noremap k j
noremap j h
noremap h ;

let XDG_SESSION_TYPE = get(environ(), 'XDG_SESSION_TYPE', '')
if XDG_SESSION_TYPE == 'x11'
  set clipboard=unnamedplus
elseif XDG_SESSION_TYPE == 'wayland'
  set clipboard=unnamed
  let g:clipboard = {
    \   'copy': {
    \       '+': ['wl-copy'],
    \       '*': ['wl-copy'],
    \   },
    \   'paste': {
    \       '+': ['wl-paste', '--no-newline'],
    \       '*': ['wl-paste', '--no-newline'],
    \   },
    \ }
endif

set tabstop=2 shiftwidth=2

" setting for vim-commentary plugin
autocmd FileType nix setlocal commentstring=#\ %s
