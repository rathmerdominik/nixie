{pkgs, ...}: {
  services.jellyseerr = {
    enable = true;
    package = pkgs.callPackage ./jellyseerr-oidc {};
    openFirewall = true;
  };
}
