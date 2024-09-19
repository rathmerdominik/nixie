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
            sclient_max_body_size 1024M;
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
          extraConfig = ''
            client_max_body_size 50000M;
          '';
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
            client_max_body_size 50000M;
          '';
        };
      };
      "series.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.sonarr;
          extraConfig = ''
            client_max_body_size 100M;
          '';
        };
      };
      "movies.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.radarr;
          extraConfig = ''
            client_max_body_size 100M;
          '';
        };
      };
      "watch.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.jellyfin;
        };
      };
      "index.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.prowlarr;
          extraConfig = ''
            client_max_body_size 100M;
          '';
        };
      };
      "manage.${domain}" = {
        enableACME = true;
        forceSSL = true;
        quic = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.homarr;
        };
      };
      "auth.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.authentik;
        };
      };
      "request.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.jellyseerr;
        };
      };
      "torrent.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.qbit;
        };
      };
      "meals.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.mealie;
        };
      };
      "paste.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.microbin;
          extraConfig = ''
            client_max_body_size 50000M;
          '';
        };
      };
      "papers.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.paperless-ngx;
          extraConfig = ''
            client_max_body_size 50000M;
          '';
        };
      };
      "roms.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.romm;
          extraConfig = ''
            client_max_body_size 50000M;
          '';
        };
      };
    };
  };
}
