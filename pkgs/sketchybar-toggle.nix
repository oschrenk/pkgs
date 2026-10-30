{
  swiftPackages,
  swiftpm,
  fetchFromGitHub,
  lib,
}:

swiftPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "sketchybar-toggle";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "malpern";
    repo = "sketchybar-toggle";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4X958atBN4Tl75lrkR9a6YVNBnGXg6ToXhUJr1UTPjE=";
  };

  # Keep item hover working on macOS 27 with topmost=on; see patch header.
  patches = [ ./sketchybar-toggle-show.patch ];

  nativeBuildInputs = [
    swiftPackages.swift
    swiftpm
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$(swiftpmBinPath)/sketchybar-toggle" $out/bin/sketchybar-toggle
    runHook postInstall
  '';

  meta = {
    description = "Hides SketchyBar while the auto-hidden macOS menu bar is revealed";
    homepage = "https://github.com/malpern/sketchybar-toggle";
    license = lib.licenses.mit;
    mainProgram = "sketchybar-toggle";
    platforms = [ "aarch64-darwin" ];
  };
})
