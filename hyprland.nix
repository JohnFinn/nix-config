{pkgs, ...}: {
  home.packages = with pkgs; [
    pkgs.wofi
  ];
}
