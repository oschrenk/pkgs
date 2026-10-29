{
  sketchybar,
  fetchFromGitHub,
  fetchpatch,
}:

sketchybar.overrideAttrs (finalAttrs: old: {
  version = "2.24.1";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fEbVzafjFTigR7TjQ41gOnDpk6S4B8qCwpz890ZNgwE=";
  };

  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/FelixKratz/SketchyBar/compare/5f358ec94d117d3e0ccc515b21fafa325940ab2d...enieuwy:SketchyBar:b64848db19a2d0aa606ff6090cb0bca3e24a7cf1.diff";
      hash = "sha256-tTzrrlz4khgyKplV0mEc6+5rj2VeZVzYX0lFpSW2YaM=";
    })
  ];

  passthru = old.passthru // {
    nixUpdateArgs = [ "--version=skip" ];
  };
})
