{
  pkgs,
  config,
  ...
}: {
  services.nginx = {
    enable = true;

    package = pkgs.nginxQuic;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    commonHttpConfig = ''
      error_log stderr;
      access_log /var/log/nginx/access.log;
    '';

    virtualHosts."~.*" = {
      default = true;
      rejectSSL = true;

      globalRedirect = config.networking.domain;
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
