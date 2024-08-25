{
  config,
  pkgs,
  ...
}: let
  ports = import ../../proxyports.nix;
  inherit (config.networking) domain;
in {
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

    virtualHosts = {
      "~.*" = {
        default = true;
        rejectSSL = true;

        globalRedirect = domain;
      };
    };
  };

  security.acme = {
    defaults.email = "security@rathmer.me";
    acceptTerms = true;
  };

  services.nginx.virtualHosts = {
    "wings.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."~ ^\/api\/servers\/(?<serverid>.*)?\/ws$" = {
        proxyWebsockets = true;
        proxyPass = "http://${ports.wings.daemon}/api/servers/$serverid/ws";
        extraConfig = ''
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };

      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://${ports.wings.daemon}";
        extraConfig = ''
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };
    };
    "bitwarden.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://${ports.vaultwarden}";
      };
    };
    "panel.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://${ports.pterodactyl}";
        extraConfig = ''
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
