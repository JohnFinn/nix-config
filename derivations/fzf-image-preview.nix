{
  imagemagick,
  chafa,
  bat,
  fd,
  fzf,
  writeShellApplication,
}:
writeShellApplication {
  name = "fzf-image-preview";
  runtimeInputs = [imagemagick chafa bat fd fzf];
  text = ''
    # shellcheck disable=SC2016
    FZF_DEFAULT_COMMAND='fd --type f' fzf --preview 'identify {} > /dev/null 2> /dev/null && chafa -f iterm --view-size $FZF_PREVIEW_COLUMNSx$FZF_PREVIEW_LINES {} || bat --color=always {}' --bind ctrl-k:down,ctrl-l:up
  '';
}
