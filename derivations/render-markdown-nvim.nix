{pkgs}:
pkgs.vimUtils.buildVimPlugin {
  pname = "render-markdown.nvim";
  version = "2024-10-27";
  src = pkgs.fetchFromGitHub {
    owner = "MeanderingProgrammer";
    repo = "render-markdown.nvim";
    rev = "fc05fb7c56795f191b6800799a2ec6ea325ba715";
    sha256 = "1604id1b0m4cj36fy8r1fnkbaxs4h388970b790mg525zz8ch6j0";
  };
  meta.homepage = "https://github.com/MeanderingProgrammer/render-markdown.nvim/";
}
