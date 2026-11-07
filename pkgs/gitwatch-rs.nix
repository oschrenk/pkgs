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
    rev = "244304b89420488b2f691f1bbf9d61afc09a1039";
    hash = "sha256-34KqMAHDWIy2E/0EpTHQ9RkO2CFZAplPX1IIGpz+RyA=";
  };

  cargoHash = "sha256-f6bwbp9aEGwSl47j6WQQkToDJpSmrFHQMyR02kxo5H8=";

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
