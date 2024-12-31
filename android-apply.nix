{
  pkgs,
  android-config,
}:
pkgs.writeShellScriptBin "android-apply" ''
  echo would install ${android-config.dfinsta}
''
