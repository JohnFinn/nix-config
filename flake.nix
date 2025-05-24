{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs_latest_stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs_latest_stable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs_latest_stable";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs_latest_stable";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs_latest_stable";
    };
  };

  outputs = {
    nixpkgs_latest_stable,
    firefox-addons,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs_latest_stable.legacyPackages.${system}.extend (import ./spotify-overlay.nix);
    ghostty = inputs.ghostty.packages.${system}.default;
    pkgs_firefox-addons = firefox-addons.packages.${system};
  in {
    nixosConfigurations.default = nixpkgs_latest_stable.lib.nixosSystem {
      modules = [./configuration.nix];
    };
    homeConfigurations."jouni" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
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
        inherit pkgs_firefox-addons;
        inherit ghostty;
      };

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [./sunnari.nix];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };
    legacyPackages.${system}.foo = pkgs.callPackage ./android-apply.nix {android-config = import ./android-config.nix;};
  };
}
