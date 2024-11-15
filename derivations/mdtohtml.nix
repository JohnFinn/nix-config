{
  buildGoModule,
  fetchFromGitHub,
}: (buildGoModule {
  name = "mdtohtml";
  vendorHash = "sha256-HzHwB0XoVjmqucqyDn44NlIG2ASPzZOKv0POiOyBxrY=";
  src = fetchFromGitHub {
    owner = "gomarkdown";
    repo = "mdtohtml";
    rev = "d773061d1585e9a85aded292f65459b2cb8b2131";
    sha256 = "sha256-GzYiiLL0yjGK70haRjoXT1QmvAjl+N/Z8H0EBhVOhRY=";
  };
})
