{pkgs, ...}: let
  stremio-enhanced = pkgs.callPackage ./packages/stremio-enhanced.nix {};
in {
  environment.systemPackages = [
    stremio-enhanced
  ];
}
