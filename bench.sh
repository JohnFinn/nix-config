#!/usr/bin/env bash
FLAGS=(--max-runs 1 --prepare 'sleep .1s')

bench() {
  hyperfine "$@" --show-output "vim --cmd 'let g:exitAfterStart=1'"
  hyperfine "$@" 'fish -c true' '/bin/wezterm start true'
}

bench "${FLAGS[@]}"
echo with sleep | cowsay
bench --min-runs 1000 --prepare 'sleep .1s'
echo without sleep | cowsay
bench --min-runs 1000
