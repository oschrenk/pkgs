{
  description = "Tools and forks, built ahead of nixpkgs and cached in oschrenk.cachix.org";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.opnix = {
    url = "github:brizzbuzz/opnix";
    flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      opnix,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
      ];
      opnixModule = import ./modules/opnix.nix {
        inherit lib opnix;
        inherit (self) packages;
      };
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
        // {
          opnix = import (opnix + "/nix/package.nix") { inherit pkgs; };
        }
      );

      nixosModules.opnix = opnixModule "/nix/module.nix";
      darwinModules.opnix = opnixModule "/nix/darwin-module.nix";

      checks = self.packages;
    };
}
