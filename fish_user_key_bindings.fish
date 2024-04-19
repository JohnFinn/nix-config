function edit_cmd --description 'Edit cmdline in editor'
  set -l f (mktemp --suffix=.fish)
  set -l p (commandline -C)
  commandline -b > $f
  vim -c set\ ft=fish $f
  commandline -r (more $f)
  commandline -C $p
  rm $f
end

function fish_user_key_bindings
 bind -k f4 edit_cmd
end
