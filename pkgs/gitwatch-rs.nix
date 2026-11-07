{
  rustPlatform,
  fetchFromGitHub,
  lib,
  libgit2,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "gitwatch-rs";
  version = "0.1.1-unstable-2026-11-07";

  # fork: adds --skip-if-merging, --pull-before-push, --pull-interval-seconds,
  # --ssh-key and a push/fetch timeout
  src = fetchFromGitHub {
    owner = "oschrenk";
    repo = "gitwatch-rs";
    rev = "38160beaf2734a39608f5e58bd89860455bf31a1";
    hash = "sha256-KoZPICCfsh+dDt2XBCUoAzR52opoG9QiphaZ/oXgqE8=";
  };

  cargoHash = "sha256-axMa1xgAoW9PA43kjuJMOxwLEgHuFxPK+0vt4kHPMxM=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    libgit2
  ];

  # use system libs from buildInputs rather than vendored copies
  env = {
    LIBGIT2_NO_VENDOR = 1;
    OPENSSL_NO_VENDOR = 1;
  };

  # tests need network or fixtures we haven't set up
  doCheck = false;

  passthru.nixUpdateArgs = [ "--version=branch=main" ];

  meta = {
    description = "Watch a git repo and automatically commit changes";
    homepage = "https://github.com/croissong/gitwatch-rs";
    license = lib.licenses.mit;
    mainProgram = "gitwatch";
  };
}
