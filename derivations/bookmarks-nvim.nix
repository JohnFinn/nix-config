{
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "bookmarks.nvim";
  version = "v2.9.1";
  src = fetchFromGitHub {
    owner = "LintaoAmons";
    repo = "bookmarks.nvim";
    rev = "a447706f8440cf473f042b9f468359b1486c9799";
    sha256 = "sha256-HinSalEKXasExUFgnYORPwpa6NHaCWZQ3zUQH4cwg+4=";
  };
  meta.homepage = "https://github.com/LintaoAmons/bookmarks.nvim/";
  meta.hydraPlatforms = [];
}
