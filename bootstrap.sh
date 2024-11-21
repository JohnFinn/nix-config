#!/bin/sh
nix run --extra-experimental-features nix-command --extra-experimental-features flakes /nix-config#bootstrap
