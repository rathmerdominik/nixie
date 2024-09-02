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
          '';
        };
      };
      "bitwarden.${domain}" = {
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
          '';
        };
      };
      "sonarr.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.sonarr;
        };
      };
      "radarr.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.radarr;
        };
      };
      "jellyfin.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.jellyfin;
        };
      };
      "prowlarr.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.prowlarr;
        };
      };
      "homarr.${domain}" = {
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
    };
    appendConfig = ''
      stream {
        server {
          listen 25566;
          proxy_pass xenon:25566;
        }
        server {
          listen 25565;
          proxy_pass xenon:25565;
        }
        server {
          listen 2022;
          proxy_pass ${mylib.formatMapping proxy-ports.wings-sftp};
        }
      }
    '';
  };
}
