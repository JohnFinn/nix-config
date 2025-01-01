{
  dfinsta = builtins.fetchurl {
    url = "https://distractionfreeapps.com/build/dfinsta_1_4_1.apk";
    sha256 = "sha256:0xkpgknzpbygyvzmkp977ibq798c6gdxjxngyjd024yi2s18ayqb";
  };
  mindthegapps = builtins.fetchurl {
    url = "https://github.com/MindTheGapps/15.0.0-arm64/releases/download/MindTheGapps-15.0.0-arm64-20240928_150548/MindTheGapps-15.0.0-arm64-20240928_150548.zip";
    sha256 = "sha256:1gk72p9v4h8s0fnpnv1xsf6fgr3jgwyzp449l4dzpimi46690h63";
  };
  lineageos-dumpling = builtins.fetchurl {
    url = "https://mirrorbits.lineageos.org/full/dumpling/20241231/lineage-22.1-20241231-nightly-dumpling-signed.zip";
    sha256 = "sha256:0ccxlqbfmjby7b03vvrmcnnciqckdpqxfbrgfvy5nxxcsyh63y6q";
  };
}
