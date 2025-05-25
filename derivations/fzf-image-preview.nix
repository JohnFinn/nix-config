{
  imagemagick,
  kitty,
  chafa,
  bat,
  gnused,
  writeShellApplication,
}:
writeShellApplication {
  name = "fzf-image-preview";
  runtimeInputs = [imagemagick kitty chafa bat gnused];
  text = ''
    file="$1"
    if identify "$file" > /dev/null 2> /dev/null
    then
      if [ -v GHOSTTY_RESOURCES_DIR ]
      # copy-pasted from https://github.com/junegunn/fzf/blob/d18c0bf6948b4707684fe77631aff26a17cbc4fa/bin/fzf-preview.sh#L68
      then kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$FZF_PREVIEW_COLUMNS"x"$FZF_PREVIEW_LINES"'@0x0' "$file" | sed '$d' | sed $'$s/$/\e[m/'
      else chafa -f iterm --view-size "$FZF_PREVIEW_COLUMNS"x"$FZF_PREVIEW_LINES" "$file"
      fi
    else bat --color=always "$file"
    fi
  '';
}
