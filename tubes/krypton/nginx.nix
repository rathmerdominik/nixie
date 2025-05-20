{
  config,
  pkgs,
  proxy-ports,
  mylib,
  ...
}: let
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
      "wings.${domain}" = {
        enableACME = true;
        forceSSL = true;
        quic = true;

        locations."~ ^\/api\/servers\/(?<serverid>.*)?\/ws$" = {
          proxyWebsockets = true;
          proxyPass = "${mylib.formatMappingHttp proxy-ports.wings}/api/servers/$serverid/ws";
          extraConfig = ''
            proxy_buffering off;
            proxy_request_buffering off;
          '';
        };

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.wings;
          extraConfig = ''
            proxy_buffering off;
            proxy_request_buffering off;
            client_max_body_size 1024m;
          '';
        };
      };
      "vault.${domain}" = {
        enableACME = true;
        forceSSL = true;
        quic = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.vaultwarden;
        };
      };
      "photos.${domain}" = {
        enableACME = true;
        forceSSL = true;
        quic = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.immich;
        };
      };
      "filebrowser.${domain}" = {
        enableACME = true;
        forceSSL = true;
        quic = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.filebrowser;
        };
      };
      "panel.${domain}" = {
        enableACME = true;
        forceSSL = true;
        quic = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.pterodactyl;
          extraConfig = ''
            proxy_buffering off;
            proxy_request_buffering off;
            client_max_body_size 1024m;
          '';
        };
      };
      "papers.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.paperless-ngx;
        };
      };
    };
  };
}
