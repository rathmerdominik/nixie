{
  config,
  pkgs,
  ...
}: {
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
    commonHttpConfig = ''
      error_log stderr;
      access_log /var/log/nginx/access.log;
    '';

    virtualHosts = let
      inherit (config.networking) domain;
    in {
      "~.*" = {
        default = true;
        rejectSSL = true;

        globalRedirect = domain;
      };
    };
  };

  security.acme = {
    defaults.email = "dominik@rathmer.me";
    acceptTerms = true;
  };
}
