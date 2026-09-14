{ pkgs, lib }:
let
  version = "2.19.2";

  # lazyjira на Linux жёстко зовёт `xclip` для копирования в буфер и глотает
  # ошибку запуска, поэтому под Wayland копирование URL молча ничего не делает.
  # Шим переводит вызов на wl-copy; на X11 аргументы уходят настоящему xclip.
  xclipShim = pkgs.writeShellApplication {
    name = "xclip";
    runtimeInputs = [ pkgs.wl-clipboard ];
    text = ''
      if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
        exec wl-copy
      fi
      exec ${pkgs.xclip}/bin/xclip "$@"
    '';
  };
in
pkgs.buildGoModule {
  pname = "lazyjira";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "textfuel";
    repo = "lazyjira";
    rev = "v${version}";
    hash = "sha256-ejisbVjzTFD6MStJ5uZfEdLwoHKS2912vKdEyl1VoAM=";
  };

  # Локальные патчи: см. файлы lazyjira-*-patch в этом каталоге.
  patches = [
    ./lazyjira-board-id.patch
    ./lazyjira-active-sprint.patch
  ];

  subPackages = [ "cmd/lazyjira" ];
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  nativeBuildInputs = [ pkgs.makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/lazyjira --prefix PATH : ${xclipShim}/bin
  '';

  # При обновлении версии: поставить lib.fakeHash, собрать пакет и взять
  # sha256 из сообщения об ошибке.
  vendorHash = "sha256-ZRN4dETJhTgBn2S3w0dMJ9itoCWt/afe8FtCABp0l7Q=";

  # Тесты ходят в Jira API, в песочнице сборки им делать нечего.
  doCheck = false;

  meta = {
    description = "Terminal UI for Jira";
    homepage = "https://github.com/textfuel/lazyjira";
    license = lib.licenses.mit;
    mainProgram = "lazyjira";
  };
}
