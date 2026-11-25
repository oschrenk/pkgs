{ lib, opnix, packages }:

# Upstream's module builds opnix on the host's nixpkgs, which never matches the cached build.
file:
let
  from = "opnix = import ./package.nix {pkgs = final;};";
  text = builtins.readFile (opnix + file);
in
assert lib.assertMsg (lib.hasInfix from text) "opnix${file} no longer contains `${from}`";
{ pkgs, ... }:
{
  imports = [
    (builtins.toFile "opnix-module.nix" (
      builtins.replaceStrings [ from ] [ "opnix = config.services.onepassword-secrets.package;" ] text
    ))
  ];

  options.services.onepassword-secrets.package = lib.mkOption {
    type = lib.types.package;
    default = packages.${pkgs.stdenv.hostPlatform.system}.opnix;
    description = "The opnix package the secrets service runs.";
  };
}
