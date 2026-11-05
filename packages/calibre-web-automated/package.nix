{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  imagemagick,
  ghostscript,
  sqlite,
  curl,
  file,
  zip,
}:

python3Packages.buildPythonApplication rec {
  pname = "calibre-web-automated";
  version = "4.0.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "crocodilestick";
    repo = "Calibre-Web-Automated";
    rev = "3ce7bf80c8c66485eec7218c6b6c3fef8e6e6ba5";
    hash = "sha256-pKcCV2ON25nWszUtPuGGIg/l8Nrrp8WnBTy3bdIyirc=";
  };

  postPatch = ''
    # Upstream's console script points at a nonexistent calibreweb package.
    substituteInPlace pyproject.toml \
      --replace-fail 'cps = "calibreweb:main"' 'cps = "cps.main:main"'

    # Version comes from a missing attr; hard-code the packaged version.
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
    sed -i '/^version = {attr/d' pyproject.toml

    # netifaces-plus is unavailable; nixpkgs' netifaces provides the same module.
    substituteInPlace pyproject.toml --replace-fail 'netifaces-plus' 'netifaces'

    # kobo_sync_utils.py lives at the repo root (not in cps/ or scripts/) and is
    # imported top-level by cps/kobo.py; the docker image has the repo root on
    # sys.path via cps.py.  Ship it as a top-level module next to cps.
    sed -i '/^\[tool.setuptools\]$/a py-modules = ["kobo_sync_utils"]' pyproject.toml

    # Restrict setuptools discovery to the cps package.
    printf '\n[tool.setuptools.packages.find]\ninclude = ["cps*"]\n' >> pyproject.toml

    # Without .git, package data (templates/static/translations) would be dropped.
    printf '\n[tool.setuptools.package-data]\ncps = ["templates/**", "static/**", "translations/**", "cache/**", "*.sql"]\n' >> pyproject.toml

    # metadata_provider/ ships without an __init__.py; add one.
    touch cps/metadata_provider/__init__.py

    # flask-limiter 4.x removed auto_check/Limiter.check(); also fix the OPDS key.
    substituteInPlace cps/__init__.py --replace-fail ', auto_check=False' ""
    substituteInPlace cps/web.py cps/usermanagement.py cps/kobo_auth.py \
      --replace-fail 'limiter.check()' 'pass  # limiter.check() removed in flask-limiter 4.x'
    substituteInPlace cps/main.py \
      --replace-fail 'return request.authorization.username' \
      'return request.authorization.username if request.authorization else ""'

    # Rewrite the hardcoded Docker paths (/config, /app, /calibre-library) to env vars.
    ${python3Packages.python.interpreter} - <<'PYEOF'
    #!/usr/bin/env python3
    """Rewrite CWA's hardcoded Docker paths for a normal Linux/NixOS install."""
    
    import pathlib
    import sys
    
    ROOT = pathlib.Path(".")
    
    SCRIPT_CFG = (
        "os.environ.get('CALIBRE_DBPATH', "
        "os.path.join(os.path.expanduser('~'), '.calibre-web-automated'))"
    )
    SCRIPT_LIB = "os.environ.get('CWA_LIBRARY_DIR', '/calibre-library')"
    
    
    def apply(path, *replacements, warn_missing=True):
        """Apply a list of (old, new) text replacements to one source file."""
        p = ROOT / path
        if not p.exists():
            if warn_missing:
                print("SKIP  %s: not found" % path, file=sys.stderr)
            return
        text = p.read_text()
        for old, new in replacements:
            if old in text:
                text = text.replace(old, new)
            elif warn_missing:
                print("WARN  %s: pattern not found: %r" % (path, old), file=sys.stderr)
        p.write_text(text)
    
    
    # Drop sys.path hacks pointing at the Docker scripts dir (now in site-packages).
    for py in ROOT.glob("cps/**/*.py"):
        text = py.read_text()
        filtered = "".join(
            line
            for line in text.splitlines(keepends=True)
            if not (
                "/app/calibre-web-automated/scripts/" in line and "sys.path" in line
            )
        )
        if filtered != text:
            py.write_text(filtered)
    
    
    # The docker image had both the repo root and scripts/ on sys.path, so
    # `from scripts.cwa_db import CWA_DB` and `from cwa_db import CWA_DB` both
    # resolved there.  Every helper script is installed directly into
    # site-packages, where only the bare form works, so normalise the imports.
    for py in ROOT.glob("cps/**/*.py"):
        text = py.read_text()
        if "from scripts.cwa_db import" in text:
            py.write_text(text.replace("from scripts.cwa_db import", "from cwa_db import"))
    
    
    # cps/ modules that import constants.
    apply(
        "cps/cwa_functions.py",
        ('LOG_ARCHIVE = "/config/log_archive"',
         'LOG_ARCHIVE = os.path.join(constants.CONFIG_DIR, "log_archive")'),
        ('DIRS_JSON = "/app/calibre-web-automated/dirs.json"',
         'DIRS_JSON = os.path.join(constants.CONFIG_DIR, "dirs.json")'),
        ("LOG_DIR = \"/config\"", "LOG_DIR = constants.CONFIG_DIR"),
        ("with open('/config/cwa_ingest_status', 'r') as f:",
         "with open(os.path.join(constants.CONFIG_DIR, 'cwa_ingest_status'), 'r') as f:"),
        ("with open('/config/cwa_ingest_retry_queue', 'r') as f:",
         "with open(os.path.join(constants.CONFIG_DIR, 'cwa_ingest_retry_queue'), 'r') as f:"),
        ('log_path = "/config/convert-library.log"',
         'log_path = os.path.join(constants.CONFIG_DIR, "convert-library.log")'),
        ("open('/config/convert-library.log', 'w').close()",
         "open(os.path.join(constants.CONFIG_DIR, 'convert-library.log'), 'w').close()"),
        ('with open("/config/convert-library.log", \'r\') as f:',
         'with open(os.path.join(constants.CONFIG_DIR, "convert-library.log"), \'r\') as f:'),
        ('log_path = "/config/epub-fixer.log"',
         'log_path = os.path.join(constants.CONFIG_DIR, "epub-fixer.log")'),
        ("open('/config/epub-fixer.log', 'w').close()",
         "open(os.path.join(constants.CONFIG_DIR, 'epub-fixer.log'), 'w').close()"),
        ('with open("/config/epub-fixer.log", \'r\') as f:',
         'with open(os.path.join(constants.CONFIG_DIR, "epub-fixer.log"), \'r\') as f:'),
        ('json_path = "/config/user_profiles.json"',
         'json_path = os.path.join(constants.CONFIG_DIR, "user_profiles.json")'),
        # subprocess spawns: use the running interpreter and the installed scripts
        ("['python3', '/app/calibre-web-automated/scripts/ingest_processor.py'",
         "[sys.executable, os.path.join(constants.BASE_DIR, 'ingest_processor.py')"),
        ("['python3', '/app/calibre-web-automated/scripts/convert_library.py'",
         "[sys.executable, os.path.join(constants.BASE_DIR, 'convert_library.py')"),
        ("['python3', '/app/calibre-web-automated/scripts/kindle_epub_fixer.py'",
         "[sys.executable, os.path.join(constants.BASE_DIR, 'kindle_epub_fixer.py')"),
        # Docker-only service health check -> trivial success on NixOS
        ("'/app/calibre-web-automated/scripts/check-cwa-services.sh'", "'true'"),
        # pkill pattern for the fixer process
        ('"/app/calibre-web-automated/scripts/kindle_epub_fixer.py"',
         'os.path.join(constants.BASE_DIR, "kindle_epub_fixer.py")'),
    )
    
    apply(
        "cps/render_template.py",
        ("'/app/cwa_update_notice'",
         "os.path.join(constants.CONFIG_DIR, 'cwa_update_notice')"),
        ("'/app/theme_migration_notice'",
         "os.path.join(constants.CONFIG_DIR, 'theme_migration_notice')"),
        ('f"/app/cwa_translation_notice_{lang}"',
         'os.path.join(constants.CONFIG_DIR, f"cwa_translation_notice_{lang}")'),
        ('po_path = f"cps/translations/{lang}/LC_MESSAGES/messages.po"',
         'po_path = os.path.join(constants.TRANSLATIONS_DIR, lang, "LC_MESSAGES", "messages.po")'),
        ('notice_file = f"/config/cwa_duplicate_index_setup_notice_{getattr(current_user, \'id\', \'unknown\')}"',
         'notice_file = os.path.join(constants.CONFIG_DIR, f"cwa_duplicate_index_setup_notice_{getattr(current_user, \'id\', \'unknown\')}")'),
    )
    
    apply(
        "cps/admin.py",
        ('"/app/CWA_RELEASE"', 'os.path.join(constants.BASE_DIR, "CWA_RELEASE")'),
        ('"/app/KEPUBIFY_RELEASE"', 'os.path.join(constants.BASE_DIR, "KEPUBIFY_RELEASE")'),
        ('"/app/CWA_STABLE_RELEASE"', 'os.path.join(constants.BASE_DIR, "CWA_STABLE_RELEASE")'),
        ('or "/config/app.db"', 'or os.path.join(constants.CONFIG_DIR, "app.db")'),
        ('backup_dir = f"/config/backup/restore_{datetime.now().strftime(\'%Y%m%d_%H%M%S\')}"',
         'backup_dir = os.path.join(constants.CONFIG_DIR, "backup", f"restore_{datetime.now().strftime(\'%Y%m%d_%H%M%S\')}")'),
        ('or "/app/calibre/calibredb"', 'or os.environ.get("CWA_CALIBREDB_PATH", "calibredb")'),
        ("default_metadata = '/calibre-library/metadata.db'",
         "default_metadata = os.path.join(" + SCRIPT_LIB + ", 'metadata.db')"),
        ("if not incoming and os.path.isfile('/calibre-library/metadata.db'):",
         "if not incoming and os.path.isfile(os.path.join(" + SCRIPT_LIB + ", 'metadata.db')):"),
        ("incoming = '/calibre-library'", "incoming = " + SCRIPT_LIB),
    )
    
    apply(
        "cps/editbooks.py",
        ("/app/calibre-web-automated/metadata_change_logs/",
         '{os.path.join(constants.CONFIG_DIR, "metadata_change_logs")}/'),
    )
    
    apply(
        "cps/web.py",
        ("with open('/app/calibre-web-automated/dirs.json', 'r') as f:",
         "with open(os.path.join(constants.CONFIG_DIR, 'dirs.json'), 'r') as f:"),
    )
    
    apply(
        "cps/constants.py",
        ('_read_text("/app/CWA_RELEASE", "v0.0.0")',
         '_read_text(os.path.join(BASE_DIR, "CWA_RELEASE"), "v0.0.0")'),
        ('_read_text("/app/CWA_STABLE_RELEASE", "v0.0.0")',
         '_read_text(os.path.join(BASE_DIR, "CWA_STABLE_RELEASE"), "v0.0.0")'),
    )
    
    apply(
        "cps/config_sql.py",
        ("fallback_db = '/calibre-library/metadata.db'",
         "fallback_db = os.path.join(" + SCRIPT_LIB + ", 'metadata.db')"),
        ('calibre_path = ["/opt/calibre/"]',
         'calibre_path = [os.environ.get("CWA_CALIBRE_BINARIES_DIR", "/opt/calibre/")]'),
        ('calibre_path = ["/usr/bin/unrar"]',
         'calibre_path = [os.environ.get("CWA_UNRAR_PATH", "/usr/bin/unrar")]'),
        ('calibre_path = ["/opt/kepubify/kepubify-linux-64bit", "/opt/kepubify/kepubify-linux-32bit"]',
         'calibre_path = [os.environ.get("CWA_KEPUBIFY_PATH", "/usr/bin/kepubify"),'
         ' "/opt/kepubify/kepubify-linux-64bit", "/opt/kepubify/kepubify-linux-32bit"]'),
    )
    
    apply(
        "cps/calibre_init.py",
        ('base_path = os.environ.get("CALIBRE_DBPATH", "/config")',
         "base_path = os.environ.get('CALIBRE_DBPATH',"
         " os.path.join(os.path.expanduser('~'), '.calibre-web-automated'))"),
    )
    
    
    # cps/ modules that do not import constants; resolve CALIBRE_DBPATH directly.
    apply(
        "cps/duplicates.py",
        ('notice_file = f"/config/cwa_duplicate_index_setup_notice_{getattr(current_user, \'id\', \'unknown\')}"',
         'notice_file = os.path.join(' + SCRIPT_CFG + ', f"cwa_duplicate_index_setup_notice_{getattr(current_user, \'id\', \'unknown\')}")'),
        ("stat = shutil_disk.disk_usage('/config')",
         "stat = shutil_disk.disk_usage(" + SCRIPT_CFG + ")"),
        ('backup_dir = f"/config/processed_books/duplicate_resolutions/{datetime.now().strftime(\'%Y%m%d_%H%M%S\')}_group_{group[\'group_hash\'][:8]}"',
         'backup_dir = os.path.join(' + SCRIPT_CFG + ', "processed_books", "duplicate_resolutions",'
         ' f"{datetime.now().strftime(\'%Y%m%d_%H%M%S\')}_group_{group[\'group_hash\'][:8]}")'),
    )
    
    apply(
        "cps/duplicate_index.py",
        ('INGEST_BATCH_DIRTY_FILE = "/config/cwa_ingest_batch_dirty"',
         'INGEST_BATCH_DIRTY_FILE = os.path.join(' + SCRIPT_CFG + ', "cwa_ingest_batch_dirty")'),
        ('INGEST_BATCH_ACTIVE_FILE = "/config/cwa_ingest_batch_active"',
         'INGEST_BATCH_ACTIVE_FILE = os.path.join(' + SCRIPT_CFG + ', "cwa_ingest_batch_active")'),
    )
    
    apply(
        "cps/tasks/ops.py",
        ('self.log_path = "/config/convert-library.log"',
         'self.log_path = os.path.join(' + SCRIPT_CFG + ', "convert-library.log")'),
        ('self.log_path = "/config/epub-fixer.log"',
         'self.log_path = os.path.join(' + SCRIPT_CFG + ', "epub-fixer.log")'),
    )
    
    apply(
        "cps/progress_syncing/settings.py",
        ('db_file = os.path.join(os.environ.get("CWA_DB_PATH", "/config"), "cwa.db")',
         'db_file = os.path.join(os.environ.get("CWA_DB_PATH", ' + SCRIPT_CFG + '), "cwa.db")'),
    )
    
    apply(
        "cps/about.py",
        ("import sys\nimport platform", "import os\nimport sys\nimport platform"),
        ('with open("/app/CWA_RELEASE", "r") as f:',
         'with open(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "CWA_RELEASE"), "r") as f:'),
    )
    
    
    # scripts/ helpers: standalone, resolve paths from the environment.
    _scripts = [
        "scripts/auto_library.py",
        "scripts/auto_zip.py",
        "scripts/convert_library.py",
        "scripts/cover_enforcer.py",
        "scripts/cwa_db.py",
        "scripts/generate_book_checksums.py",
        "scripts/generate_translation_status.py",
        "scripts/ingest_processor.py",
        "scripts/kindle_epub_fixer.py",
        "scripts/watch_fallback.py",
    ]
    
    for script in _scripts:
        apply(
            script,
            # f-string / slash-suffixed variants must be replaced before the plain ones
            ('output_path = f"/config/processed_books/fixed_originals/"',
             'output_path = os.path.join(' + SCRIPT_CFG + ', "processed_books", "fixed_originals") + "/"'),
            ('output_path = f"/config/processed_books/failed/{os.path.basename(target_filepath)}"',
             'output_path = os.path.join(' + SCRIPT_CFG + ', "processed_books", "failed",'
             " os.path.basename(target_filepath))"),
            ('self.archive_dirs_stem = "/config/processed_books/"',
             'self.archive_dirs_stem = os.path.join(' + SCRIPT_CFG + ', "processed_books") + "/"'),
            ('"/config/processed_books/"',
             'os.path.join(' + SCRIPT_CFG + ', "processed_books") + "/"'),
            ('"/config/processed_books"', 'os.path.join(' + SCRIPT_CFG + ', "processed_books")'),
            ('"/config/app.db"', 'os.path.join(' + SCRIPT_CFG + ', "app.db")'),
            ('"/config/convert-library.log"',
             'os.path.join(' + SCRIPT_CFG + ', "convert-library.log")'),
            ('"/config/epub-fixer.log"', 'os.path.join(' + SCRIPT_CFG + ', "epub-fixer.log")'),
            ("'/config/.cwa_db_debug'", 'os.path.join(' + SCRIPT_CFG + ', ".cwa_db_debug")'),
            ('"/config/cwa_ingest_batch_dirty"',
             'os.path.join(' + SCRIPT_CFG + ', "cwa_ingest_batch_dirty")'),
            ('"/config/cwa_ingest_batch_active"',
             'os.path.join(' + SCRIPT_CFG + ', "cwa_ingest_batch_active")'),
            ('self.config_dir = "/config"', "self.config_dir = " + SCRIPT_CFG),
            ('self.calibre_env["HOME"] = "/config"',
             'self.calibre_env["HOME"] = ' + SCRIPT_CFG),
            ('os.environ.get("CWA_DB_PATH", "/config")',
             'os.environ.get("CWA_DB_PATH", ' + SCRIPT_CFG + ')'),
            ('os.environ.get("CALIBRE_DBPATH", "/config")',
             "os.environ.get('CALIBRE_DBPATH',"
             " os.path.join(os.path.expanduser('~'), '.calibre-web-automated'))"),
            # dirs.json / metadata dirs
            ('"/app/calibre-web-automated/dirs.json"',
             'os.path.join(' + SCRIPT_CFG + ', "dirs.json")'),
            ("'/app/calibre-web-automated/dirs.json'",
             "os.path.join(" + SCRIPT_CFG + ", 'dirs.json')"),
            ('"/app/calibre-web-automated/metadata_change_logs"',
             'os.path.join(' + SCRIPT_CFG + ', "metadata_change_logs")'),
            ('"/app/calibre-web-automated/metadata_temp"',
             'os.path.join(' + SCRIPT_CFG + ', "metadata_temp")'),
            # empty_library ships next to the installed scripts
            ('"/app/calibre-web-automated/empty_library/app.db"',
             'os.path.join(os.path.dirname(os.path.abspath(__file__)), "empty_library", "app.db")'),
            ('"/app/calibre-web-automated/empty_library/metadata.db"',
             'os.path.join(os.path.dirname(os.path.abspath(__file__)), "empty_library", "metadata.db")'),
            # Calibre library location
            ('self.library_dir = "/calibre-library"', "self.library_dir = " + SCRIPT_LIB),
            ('"/calibre-library/metadata.db"',
             'os.path.join(' + SCRIPT_LIB + ', "metadata.db")'),
            ("'/calibre-library/metadata.db'",
             "os.path.join(" + SCRIPT_LIB + ", 'metadata.db')"),
            ("default='/calibre-library'", "default=" + SCRIPT_LIB),
            warn_missing=False,
        )
    
    # ── Cover downloads (Litres and other CDNs) ─────────────────────────────
    # Follow redirects: the cover CDN answers with a 302 stub, which the old
    # allow_redirects=False surfaced as text/html and rejected.
    apply("cps/helper.py",
        ("allow_redirects=False", "allow_redirects=True"))
    # Some CDNs omit/misreport Content-Type; sniff the magic bytes in save_cover().
    apply("cps/helper.py",
        ("            content_type = content_type.split(separator)[0].strip()\n\n    if use_IM:",
         "            content_type = content_type.split(separator)[0].strip()\n\n"
         "    # Nix: some cover CDNs omit or misreport Content-Type; sniff magic bytes.\n"
         "    if (content_type or \"\").lower() in (\"\", \"application/octet-stream\",\n"
         "                                          \"binary/octet-stream\", \"text/html\"):\n"
         "        try:\n"
         "            import magic\n"
         "            buf = getattr(img, \"content\", None) or getattr(img, \"_content\", None)\n"
         "            if buf:\n"
         "                content_type = magic.from_buffer(bytes(buf[:2048]), mime=True)\n"
         "        except Exception:\n"
         "            pass\n\n"
         "    if use_IM:"))

    # ── Docker-parity chown (seccomp kills chown on NixOS) ──────────────────
    # editbooks.py chowned the ingest dir to uid/gid 1000 (docker's user) on
    # every web upload; systemd's SystemCallFilter kills the process with
    # SIGSYS.  The service user already owns the dir, so drop the call.
    apply("cps/editbooks.py",
        ("os.chown(ingest_dir, 1000, 1000)",
         "pass  # Nix: service user owns the ingest dir; docker-parity chown removed (seccomp blocks chown)"))
    # scripts/convert_library.py looks up the docker user at import time;
    # guard it (as kindle_epub_fixer.py already does) and the numeric chown.
    apply("scripts/convert_library.py",
        ("uid = pwd.getpwnam(USER_NAME).pw_uid\ngid = grp.getgrnam(GROUP_NAME).gr_gid",
         "uid = None\ngid = None\ntry:\n    uid = pwd.getpwnam(USER_NAME).pw_uid\n    gid = grp.getgrnam(GROUP_NAME).gr_gid\nexcept KeyError:\n    pass  # Nix: no 'abc' user; skip ownership operations"),
        ("        subprocess.run([\"chown\", f\"{uid}:{gid}\", convert_library_log_file], check=True)",
         "        if uid is not None and gid is not None:\n            subprocess.run([\"chown\", f\"{uid}:{gid}\", convert_library_log_file], check=True)"))

    # Fail the build if any of the surgical edits above silently no-op'd.
    for _f, _marker in (
        ("cps/helper.py", "magic.from_buffer"),
        ("cps/editbooks.py", "docker-parity chown removed"),
        ("scripts/convert_library.py", "no 'abc' user"),
    ):
        assert _marker in (ROOT / _f).read_text(), "patch missing in %s" % _f

    print("All Docker path patches applied successfully.")
    PYEOF

    # Docker generates this KOReader plugin archive; upstream doesn't ship it in git.
    if [ -d koreader/plugins/cwasync.koplugin ]; then
      ( cd koreader/plugins && zip -rq -X ../../cps/static/koplugin.zip cwasync.koplugin )
      test -s cps/static/koplugin.zip
    fi
  '';

  build-system = [ python3Packages.setuptools ];
  nativeBuildInputs = [ zip ];

  # CWA pins old upper bounds that predate current nixpkgs; strip every pin.
  pythonRelaxDeps = true;

  # `optional-dependencies` is passthru-only in nixpkgs, so extras are merged into `dependencies`.
  optional-dependencies = {
    comics = with python3Packages; [
      comicapi
      natsort
    ];

    gdrive = with python3Packages; [
      gevent
      google-api-python-client
      greenlet
      httplib2
      oauth2client
      pyasn1-modules
      # pydrive2 is broken in nixpkgs, so the Google Drive v2 backend is unavailable.
      # pydrive2
      pyyaml
      rsa
    ];

    gmail = with python3Packages; [
      google-api-python-client
      google-auth-oauthlib
    ];

    kobo = with python3Packages; [ jsonschema ];

    ldap = with python3Packages; [
      flask-simpleldap
      python-ldap
    ];

    metadata = with python3Packages; [
      beautifulsoup4
      faust-cchardet
      html2text
      markdown2
      mutagen
      py7zr
      python-dateutil
      rarfile
      scholarly
    ];

    oauth = with python3Packages; [
      flask-dance
      sqlalchemy-utils
    ];

    # `goodreads` and `curl-cffi` extras are skipped (not in nixpkgs / optional upstream).
  };

  dependencies = with python3Packages; [
    apscheduler
    babel
    bleach
    certifi
    chardet
    charset-normalizer
    cryptography
    flask
    flask-babel
    flask-httpauth
    flask-limiter
    flask-principal
    flask-wtf
    idna
    iso-639
    lxml
    # Provides the `netifaces` module the project pins as netifaces-plus.
    netifaces
    polib
    pycountry
    pypdf
    python-magic
    pytz
    qrcode
    regex
    requests
    sqlalchemy
    tabulate
    tornado
    unidecode
    urllib3
    wand
  ] ++ lib.concatAttrValues optional-dependencies;

  postInstall = ''
    site="$out/${python3Packages.python.sitePackages}"

    # Helper scripts cps spawns via subprocess or imports directly.
    cp scripts/*.py "$site/"
    cp scripts/*.sql "$site/"

    # Seeding data for a fresh app.db / Calibre library.
    mkdir -p "$site/empty_library"
    cp empty_library/app.db empty_library/metadata.db "$site/empty_library/"

    # Version stamps read from BASE_DIR; env CWA_*_VERSION takes precedence.
    echo "v${version}" > "$site/CWA_RELEASE"
    echo "v${version}" > "$site/CWA_STABLE_RELEASE"
    echo "v0.0.0"      > "$site/KEPUBIFY_RELEASE"

    # Sentinel: makes the writable per-user config root the default, not BASE_DIR.
    touch "$site/cps/.HOMEDIR"

    # cwa-ingest: one ingest pass over the folder recorded in dirs.json.
    cat > "$out/bin/cwa-ingest" <<'CWA_INGEST'
#!/usr/bin/env python3
"""Run a single Calibre-Web-Automated ingest pass over the configured folder."""
import json
import os
import sys

config_dir = os.environ.get("CALIBRE_DBPATH") or os.path.join(
    os.path.expanduser("~"), ".calibre-web-automated"
)

ingest_folder = None
dirs_file = os.path.join(config_dir, "dirs.json")
try:
    with open(dirs_file, encoding="utf-8") as fh:
        ingest_folder = json.load(fh).get("ingest_folder")
except OSError as exc:
    print(f"[cwa-ingest] cannot read {dirs_file}: {exc}", file=sys.stderr)
except ValueError as exc:
    print(f"[cwa-ingest] invalid JSON in {dirs_file}: {exc}", file=sys.stderr)

if not ingest_folder and len(sys.argv) > 1:
    ingest_folder = sys.argv[1]

if not ingest_folder:
    print(
        "[cwa-ingest] no ingest folder configured; write dirs.json or pass a path",
        file=sys.stderr,
    )
    sys.exit(2)

if not os.path.isdir(ingest_folder):
    print(f"[cwa-ingest] ingest folder does not exist: {ingest_folder}", file=sys.stderr)
    sys.exit(0)

from ingest_processor import main

sys.exit(main(ingest_folder))
CWA_INGEST
    chmod +x "$out/bin/cwa-ingest"
  '';

  # Make the installed helper scripts directly executable.
  postFixup = ''
    site="$out/${python3Packages.python.sitePackages}"
    for s in "$site"/*.py; do
      if [ -f "$s" ] && head -c 2 "$s" | grep -q '#!'; then
        patchPythonScript "$s"
      fi
    done
  '';

  # With __structuredAttrs the list is passed to the wrapper hook verbatim, so
  # every flag and its operands need their own element: a single
  # "--prefix PATH : ..." string reaches makeWrapper as one unrecognised word.
  makeWrapperArgs = lib.optionals stdenv.hostPlatform.isLinux [
    # Wand/python-magic shell out to binaries; calibre/kepubify/unrar come from the module.
    "--prefix" "PATH" ":" (lib.makeBinPath [ imagemagick ghostscript sqlite curl file ])
    # constants.py prefers these over the version files.
    "--set" "CWA_INSTALLED_VERSION" "v${version}"
    "--set" "CWA_STABLE_VERSION" "v${version}"
  ];

  # Importing cps creates $HOME/.calibre-web-automated, so HOME must be writable.
  preInstall = ''
    export HOME="$TMPDIR"
  '';

  # Cover the modules that crash at startup if a top-level repo module is
  # missing (e.g. kobo_sync_utils, imported by cps/kobo.py).
  pythonImportsCheck = [
    "cps"
    "cps.main"
    "cps.kobo"
    "cps.progress_syncing.protocols.kosync"
    "kobo_sync_utils"
    "cwa_db"
    "cwa_internal_auth"
  ];

  # Tests need a running Calibre library and a writable HOME; skip them.
  doCheck = false;

  meta = {
    description = "Calibre-Web with automated library management and many new features";
    longDescription = ''
      Calibre-Web Automated is a fork of Calibre-Web that adds automated book
      ingest, format conversion, metadata enforcement, duplicate detection,
      Kobo/KOReader sync and Hardcover metadata integration.
    '';
    homepage = "https://github.com/crocodilestick/Calibre-Web-Automated";
    changelog = "https://github.com/crocodilestick/Calibre-Web-Automated/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "cps";
    platforms = lib.platforms.all;
  };
}
