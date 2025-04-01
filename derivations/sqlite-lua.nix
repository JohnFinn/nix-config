{
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "sqlite.lua";
  version = "2025-03-14";
  src = fetchFromGitHub {
    owner = "kkharji";
    repo = "sqlite.lua";
    rev = "50092d60feb242602d7578398c6eb53b4a8ffe7b";
    sha256 = "157wz9nka7g66ywyrqrni64g3a45k60v49l18ym6ipk0g3xji8xv";
  };
  meta.homepage = "https://github.com/kkharji/sqlite.lua/";
  meta.hydraPlatforms = [];
}
