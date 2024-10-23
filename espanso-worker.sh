#!/usr/bin/env fish
sudo -E capsh --keep=1 --user=(whoami) --caps="cap_dac_override+pei" --addamb="cap_dac_override"  -- -c 'espanso worker'

