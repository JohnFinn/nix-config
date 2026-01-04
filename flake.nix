{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs_unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs_latest_stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs_latest_stable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs_latest_stable";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs_latest_stable";
    };
    web_vim_remap = {
      url = "github:JohnFinn/web_vim_remap";
      inputs.nixpkgs.follows = "nixpkgs_latest_stable";
    };
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
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
    pkgs_firefox-addons = firefox-addons.packages.${system};
    web_vim_remap_firefox_extension = inputs.web_vim_remap.packages.${system}.firefox_extension;
  in {
    nixosConfigurations.default = nixpkgs_latest_stable.lib.nixosSystem {
      modules = [./configuration.nix];
    };
    homeConfigurations."jouni" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit pkgs_firefox-addons;
        inherit web_vim_remap_firefox_extension;
      };

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [./jouni.nix];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };

    homeConfigurations."dzhouni.sunnari" = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs.extend inputs.nixgl.overlay;
      extraSpecialArgs = {
        inherit pkgs_firefox-addons;
        inherit web_vim_remap_firefox_extension;
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
