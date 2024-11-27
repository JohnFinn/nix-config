{
  vimUtils,
  fetchFromGitHub,
  lib,
}:
vimUtils.buildVimPlugin {
  pname = "match-visual.nvim";
  version = "2024-04-29";
  src = fetchFromGitHub {
    owner = "aaron-p1";
    repo = "match-visual.nvim";
    rev = "98540e79c151126187907278ff5bc61823edcebc";
    sha256 = "sha256-wYBueqOcIfqJOFjdSAUHe8725i9dKmwqTxaNWW3gmg4=";
  };
  meta.homepage = "https://github.com/aaron-p1/match-visual.nvim/";
}
