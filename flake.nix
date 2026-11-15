{
  description = "Tools and forks, built ahead of nixpkgs and cached in oschrenk.cachix.org";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
      ];
    in
    {
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        lib.filterAttrs (_: lib.meta.availableOn pkgs.stdenv.hostPlatform) (
          lib.packagesFromDirectoryRecursive {
            inherit (pkgs) callPackage;
            directory = ./pkgs;
          }
        )
      );

      checks = self.packages;
    };
}
