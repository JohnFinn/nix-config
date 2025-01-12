{pkgs, ...}: {
  home.packages = with pkgs; [
    pkgs.wofi
    pkgs.blueberry
  ];
}
