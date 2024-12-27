{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs_old.url = "github:nixos/nixpkgs/1042fd8b148a9105f3c0aca3a6177fd1d9360ba5";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs_old,
    firefox-addons,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system}.extend (import ./spotify-overlay.nix);
    ghostty = inputs.ghostty.packages.${system}.default;
    pkgs_old = import nixpkgs_old {
      inherit system;
    };
    pkgs_firefox-addons = firefox-addons.packages.${system};
  in {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      modules = [./configuration.nix];
    };
    homeConfigurations."jouni" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit pkgs_old;
        inherit pkgs_firefox-addons;
        inherit ghostty;
      };

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [./jouni.nix];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };

    homeConfigurations."sunnari" = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs.extend inputs.nixgl.overlay;
      extraSpecialArgs = {
        inherit pkgs_old;
        inherit pkgs_firefox-addons;
        inherit ghostty;
      };

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [./sunnari.nix];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };
  };
}
