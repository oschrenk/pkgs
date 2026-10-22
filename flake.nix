{
  description = "Tools and forks, built ahead of nixpkgs and cached in oschrenk.cachix.org";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = pkgs.lib.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage;
        directory = ./pkgs;
      };

      checks.${system} = self.packages.${system};
    };
}
