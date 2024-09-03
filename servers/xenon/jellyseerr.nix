{pkgs, ...}: {
  services.jellyseerr = {
    enable = true;
    package = pkgs.callPackage ./jellyseer-oidc {};
    openFirewall = true;
  };
}
