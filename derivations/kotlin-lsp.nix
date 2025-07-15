{
  lib,
  stdenv,
  fetchzip,
  openjdk,
  gradle,
  makeWrapper,
  maven,
}:
stdenv.mkDerivation rec {
  pname = "kotlin-lsp";
  version = "0.252.17811";
  src = fetchzip {
    stripRoot = false;
    url = "https://download-cdn.jetbrains.com/kotlin-lsp/${version}/kotlin-${version}.zip";
    hash = "sha256-yplwz3SQzUIYaOoqkvPEy8nQ5p3U/e1O49WNxaE7p9Y=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -r lib/ $out/bin
    cp kotlin-lsp.sh $out/bin/kotlin-lsp
    chmod +x $out/bin/kotlin-lsp
  '';

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];
  buildInputs = [
    openjdk
    gradle
  ];

  postFixup = ''
    wrapProgram "$out/bin/kotlin-lsp" --set JAVA_HOME ${openjdk} --prefix PATH : ${
      lib.strings.makeBinPath [
        openjdk
        maven
      ]
    }
  '';

  meta = {
    description = "kotlin language server";
    maintainers = [];
    homepage = "https://github.com/Kotlin/kotlin-lsp";
    platforms = lib.platforms.unix;
    sourceProvenance = [lib.sourceTypes.binaryBytecode];
  };
}
