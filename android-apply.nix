{
  pkgs,
  android-config,
}:
pkgs.writeShellScriptBin "android-apply" ''
  adb install ${android-config.dfinsta}
  ${./android-config.fish}
''
