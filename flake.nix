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
      # every pkgs/<name>.nix becomes packages.<system>.<name>
      packages.${system} = pkgs.lib.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage;
        directory = ./pkgs;
      };

      # lets `nix flake check` build every package
      checks.${system} = self.packages.${system};
    };
}
