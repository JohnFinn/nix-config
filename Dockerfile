FROM nixos/nix
COPY . /nix-config
ENTRYPOINT ["/nix-config/bootstrap.sh"]
