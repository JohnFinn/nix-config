{pkgs, ...} @ inputs: {
  imports = [
    ./theme.nix
    ./gui-apps.nix
    ({pkgs, ...}: {
      home.packages = [pkgs.easyeffects];
      xdg.configFile = {
        "easyeffects/output".source = pkgs.fetchFromGitHub {
          owner = "Digitalone1";
          repo = "EasyEffects-Presets";
          rev = "32d0f416e7867ccffdab16c7fe396f2522d04b2e";
          sha256 = "sha256-U9SSyHOOs8GsV6GBEqAqlBAuYONeh/4nkK8HurkEfWk=";
        };
        "conky".source = ./dotfiles/conky;
      };
    })
  ];
}
