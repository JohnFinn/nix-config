{
  config,
  pkgs,
  ...
}: let
  espanso = pkgs.espanso.override {
    waylandSupport = true;
    x11Support = false;
  };
in {
  services.espanso = {
    enable = true;
    # wayland = true;
    package = espanso;
  };

  security.wrappers = {
    espanso = {
      source = "${espanso}/bin/.espanso-wrapped";
      owner = "root";
      group = "root";
      capabilities = "cap_dac_override+p";
    };
  };
}
