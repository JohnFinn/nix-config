#!/usr/bin/env bash
FLAGS="--max-runs 1"
hyperfine $FLAGS --show-output "vim --cmd 'let g:exitAfterStart=1'"
hyperfine $FLAGS 'fish -c true' '/bin/wezterm start true'
