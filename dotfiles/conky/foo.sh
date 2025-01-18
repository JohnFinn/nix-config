#!/usr/bin/env bash
export PATH=$PATH:$HOME/.nix-profile/bin
inotifywait ~/Sync/todo.txt/todo.txt
todo.sh -p list @sprint | sd '^\d+ |rec:\w+|due:\d{4}-\d{2}-\d{2}|t:\d{4}-\d{2}-\d{2}|\d{4}-\d{2}-\d{2}|@sprint' ''
