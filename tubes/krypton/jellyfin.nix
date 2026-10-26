{
  lib,
  pkgs,
  mylib,
  config,
  proxy-ports,
  ...
}: let
  domain = "movies.${config.networking.domain}";
in {
  services.jellyfin = {
    enable = true;
    logDir = "/var/log/jellyfin";
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    quic = true;

    locations."/" = {
      proxyPass = mylib.formatMappingHttp proxy-ports.jellyfin;
    };
  };
}
