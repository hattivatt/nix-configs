{ pkgs, ... }:
let
  fbreader-appimage = pkgs.fetchurl {
    url = "https://fbreader.org/static/packages/linux/FBReader_Book_Reader-x86_64-2.1.4.AppImage";
    hash = "sha256-3kpQRPVmoEtMWU/wQ8E3173ZnpUeQaRRLoFNkPaXhXE=";
  };

  fbreader-extracted = pkgs.appimageTools.extract {
    pname = "fbreader";
    version = "2.1.4";
    src = fbreader-appimage;
  };

  # Внутри AppImage статически слинкованы libcurl+OpenSSL, собранные с
  # OPENSSLDIR="/etc/ssl": curl ищет CA по захардкоженному capath
  # /etc/ssl/certs (хэшированные имена <hash>.0), поэтому SSL_CERT_FILE /
  # SSL_CERT_DIR он игнорирует. На NixOS в /etc/ssl/certs есть только
  # ca-certificates.crt без хэш-симлинков. Подкладываем в песочницу
  # правильный /etc/ssl: бандл как cert.pem + хэш-симлинки + openssl.cnf.
  etc-ssl = pkgs.runCommand "etc-ssl" { } ''
    mkdir -p $out/certs
    cp ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt $out/cert.pem

    # бандл -> отдельные PEM-файлы (openssl rehash требует ровно один
    # сертификат на файл)
    ${pkgs.python3}/bin/python3 -c "
import re
data = open('${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt').read()
blocks = re.findall(r'-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----', data, re.S)
for i, b in enumerate(blocks):
    open('$out/certs/%04d.pem' % i, 'w').write(b + '\n')
"

    ${pkgs.openssl}/bin/openssl rehash $out/certs
    cp ${pkgs.openssl.out}/etc/ssl/openssl.cnf $out/openssl.cnf
  '';
in
pkgs.buildFHSEnv {
  name = "fbreader";

  targetPkgs = pkgs: with pkgs; [
    icu66
    sqlite
    zlib
    qt6.qtbase
    libsecret
    glib
    bzip2
    xz
    libGL
    libglvnd
    openssl
    cacert
    e2fsprogs
    krb5
    keyutils
    fontconfig
    freetype
    libX11
    libxcb
    libgpg-error
  ];

  # --ro-bind добавляется в конец bwrap-аргументов, т.е. перекрывает
  # симлинк хостовой /etc/ssl/certs, который buildFHSEnv создаёт раньше.
  extraBwrapArgs = [
    "--ro-bind ${etc-ssl} /etc/ssl"
  ];

  runScript = pkgs.writeShellScript "fbreader-run" ''
    export QT_QPA_PLATFORM=xcb
    exec ${fbreader-extracted}/usr/bin/FBReader "$@"
  '';
}
