#!/usr/bin/env bash
FLAGS="--max-runs 1"
hyperfine $FLAGS --show-output "vim --cmd 'let g:exitAfterStart=1'" 
