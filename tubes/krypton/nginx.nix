{
  config,
  pkgs,
  ...
}: {
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

  services.nginx = {
    virtualHosts = {
      "~.*" = {
        default = true;
        rejectSSL = true;

        globalRedirect = config.networking.domain;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
