{
  swiftPackages,
  fetchFromGitHub,
  lib,
  rcodesign,
}:

swiftPackages.stdenv.mkDerivation {
  pname = "despacer";
  version = "0-unstable-2026-10-22";

  # Upstream has no tags or releases, so this pins a revision.
  src = fetchFromGitHub {
    owner = "MattSenter";
    repo = "despacer";
    rev = "aa9f75ca9bd7611e714b83352a89ca5c39265c85";
    hash = "sha256-m4RjEf2eXox1tvVFF82PkuukvZDxUENV4mB0qjPlY9A=";
  };

  # Point the transcript lookup at ~/.config/claude; see patch header.
  patches = [ ./despacer-transcript-roots.patch ];

  nativeBuildInputs = [
    swiftPackages.swift
    rcodesign
  ];

  # Mirrors upstream build.sh, minus `xcrun actool`, which needs Xcode; the
  # prebuilt AppIcon.icns that Info.plist names via CFBundleIconFile ships instead.
  buildPhase = ''
    runHook preBuild
    app=Despacer.app/Contents
    mkdir -p $app/MacOS $app/Resources
    cp Info.plist $app/Info.plist
    substituteInPlace $app/Info.plist \
      --replace-fail '$(MARKETING_VERSION)' 1.0 \
      --replace-fail '$(CURRENT_PROJECT_VERSION)' 1
    cp Resources/AppIcon.icns Resources/MenuBarIcon*.png $app/Resources/
    cp -R Resources/other-projects Localization/*.lproj $app/Resources/
    swiftc -O -swift-version 5 -target arm64-apple-macos14.0 -module-name Despacer \
      -o $app/MacOS/Despacer App/*.swift Sources/DespacerCore/*.swift
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R Despacer.app $out/Applications/
    runHook postInstall
  '';

  # Ad-hoc bundle signature, as upstream's `codesign --sign -`. It must run
  # after fixup, whose strip and per-file re-sign would break it. sigtool
  # cannot sign bundles, and /usr/bin/codesign is outside the sandbox.
  postFixup = ''
    rcodesign sign --binary-identifier Despacer=com.mattsenter.Despacer \
      $out/Applications/Despacer.app
  '';

  passthru.nixUpdateArgs = [ "--version=branch" ];

  meta = {
    description = "Menu bar app that rejoins terminal copies wrapped by Claude Code";
    homepage = "https://github.com/MattSenter/despacer";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
