{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain;
in {
  services.nginx = {
    enable = true;
    package = pkgs.nginx;

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    commonHttpConfig = ''
      error_log stderr;
      access_log /var/log/nginx/access.log;
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx = {
    virtualHosts = {
      "~.*" = {
        default = true;
        rejectSSL = true;

        globalRedirect = domain;
      };
    };
  };
}
