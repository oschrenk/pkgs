{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  openssl,
  pdfium,
}:

# Upstream's aarch64 release binary. The nixpkgs derivation pulls webkitgtk,
# which has no cached aarch64-linux build. Drop this file once cache.nixos.org
# serves the nixpkgs stump for aarch64-linux.
stdenv.mkDerivation (finalAttrs: {
  pname = "stump";
  version = "0.1.13";

  src = fetchurl {
    url = "https://github.com/stumpapp/stump/releases/download/v${finalAttrs.version}/linux-arm-build-results.zip";
    hash = "sha256-IhL0ZkFNxp/8kqijlF+hKbeBX247a+rM0U+ZRj/bJps=";
  };

  # The zip carries stump_server and client/ at the top level, with no wrapping
  # directory for the default sourceRoot to find.
  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
  ];

  # `patchelf --print-needed` names libssl.so.3 and libcrypto.so.3 from openssl,
  # libstdc++.so.6 and libgcc_s.so.1 from the stdenv C++ runtime, and nothing
  # else outside libc.
  buildInputs = [
    openssl
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 stump_server $out/bin/stump_server
    mkdir -p $out/share/stump
    cp -r client $out/share/stump/client

    runHook postInstall
  '';

  # stump builds pdfium-render against its dynamic bindings, so the server
  # dlopens libpdfium through PDFIUM_PATH and renders no PDF page without it.
  # All three mirror the wrapper the nixpkgs derivation writes.
  postFixup = ''
    wrapProgram $out/bin/stump_server \
      --set-default STUMP_CLIENT_DIR $out/share/stump/client \
      --set-default PDFIUM_PATH ${pdfium}/lib/libpdfium.so \
      --set-default STUMP_PROFILE release
  '';

  meta = {
    description = "Free and open source comics, manga and digital book server with OPDS support";
    homepage = "https://stumpapp.dev";
    license = lib.licenses.mit;
    mainProgram = "stump_server";
    platforms = [ "aarch64-linux" ];
  };
})
