{
  imagemagick,
  chafa,
  bat,
  writeShellApplication,
}:
# TODO: try using this to make ghostty work https://github.com/junegunn/fzf/blob/d18c0bf6948b4707684fe77631aff26a17cbc4fa/bin/fzf-preview.sh#L68
writeShellApplication {
  name = "fzf-image-preview";
  runtimeInputs = [imagemagick chafa bat];
  text = ''
    file="$1"
    if identify "$file" > /dev/null 2> /dev/null
    then chafa -f iterm --view-size "$FZF_PREVIEW_COLUMNS"x"$FZF_PREVIEW_LINES" "$file"
    else bat --color=always "$file"
    fi
  '';
}
