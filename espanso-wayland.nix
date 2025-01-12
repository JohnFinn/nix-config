{
  config,
  pkgs,
  lib,
  ...
}: let
  espanso = pkgs.espanso.override {
    waylandSupport = true;
    x11Support = false;
  };
  path = lib.makeBinPath [
    pkgs.libnotify
    pkgs.wl-clipboard
    pkgs.coreutils
  ];
in {
  systemd.user.services.espanso = {
    description = "Espanso daemon";
    serviceConfig = {
      Environment = ''"PATH=${path}"'';
      ExecStart = "${config.security.wrapperDir}/espanso worker";
      Restart = "on-failure";
    };
    wantedBy = ["default.target"];
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
