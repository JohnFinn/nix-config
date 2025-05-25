{
  imagemagick,
  chafa,
  bat,
  fd,
  fzf,
  writeShellApplication,
}:
# TODO: try using this to make ghostty work https://github.com/junegunn/fzf/blob/d18c0bf6948b4707684fe77631aff26a17cbc4fa/bin/fzf-preview.sh#L68
writeShellApplication {
  name = "fzf-image-preview";
  runtimeInputs = [imagemagick chafa bat fd fzf];
  text = ''
    # shellcheck disable=SC2016
    FZF_DEFAULT_COMMAND='fd --type f' fzf --preview 'identify {} > /dev/null 2> /dev/null && chafa -f iterm --view-size $FZF_PREVIEW_COLUMNSx$FZF_PREVIEW_LINES {} || bat --color=always {}' --bind ctrl-k:down,ctrl-l:up
  '';
}
