{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  buildNpmPackage,
  nodejs_24,
  makeWrapper,
  git,
  source ? fetchFromGitHub {
    owner = "hattivatt";
    repo = "campaign-bot";
    rev = "v0.5.0";
    hash = "sha256-IyQLpSSyocVSHvrGZrSePoe+XRYU3I2jqQ9Xtu4jfEc=";
  },
}:

buildNpmPackage (finalAttrs: {
  pname = "campaign-bot";
  version = "0.5.0";

  src = source;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-PEMIj7uqftn8oFWBm0KYA4HTH1tjGJLxA1SlTD2VYMs=";
  };

  nodejs = nodejs_24;

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    mkdir -p $out/share/campaign-bot $out/bin

    cp -r src prompts package.json $out/share/campaign-bot/
    cp -r node_modules $out/share/campaign-bot/node_modules

    makeWrapper ${nodejs_24}/bin/node $out/bin/campaign-bot \
      --add-flags $out/share/campaign-bot/src/index.ts \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  doInstallCheck = false;

  meta = {
    description = "Discord bot that runs tabletop RPG campaigns with an LLM, Foundry VTT and a git-backed wiki";
    homepage = "https://github.com/hattivatt/campaign-bot";
    changelog = "https://github.com/hattivatt/campaign-bot/commits/main";
    mainProgram = "campaign-bot";
    platforms = lib.platforms.linux;
  };
})
