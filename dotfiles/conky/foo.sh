#!/usr/bin/env bash
export PATH=$PATH:$HOME/.nix-profile/bin
ppidfile=/tmp/.conky-todotxt
invocation_id="$(ps -p $PPID -o pid,lstart --no-headers)"
if [ -e $ppidfile ] && [ "$(cat $ppidfile)" == "$invocation_id" ]; then
  inotifywait ~/Sync/todo.txt/todo.txt > /dev/null
else
  echo "$invocation_id" > $ppidfile
fi
todo.sh -p list @sprint | sd '^\d+ |rec:\w+|due:\d{4}-\d{2}-\d{2}|t:\d{4}-\d{2}-\d{2}|\d{4}-\d{2}-\d{2}|@sprint' ''
