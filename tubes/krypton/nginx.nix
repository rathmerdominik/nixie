{
  config,
  pkgs,
  proxy-ports,
  mylib,
  ...
}: let
  inherit (config.networking) domain;
  secondDomain = "rathmer.me";
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
          extraConfig = ''
            client_max_body_size 1024M;
          '';
        };
      };
      "panel.${domain}" = {
        enableACME = true;
        forceSSL = true;
        quic = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = mylib.formatMappingHttp proxy-ports.pelican;
          extraConfig = ''
            proxy_buffering off;
            proxy_request_buffering off;
            client_max_body_size 1024M;
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
      "backup.${domain}" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = mylib.formatMappingHttp proxy-ports.backrest;
          extraConfig = ''
            proxy_connect_timeout 300;
            proxy_send_timeout 300;
            proxy_read_timeout 300;
            proxy_buffering off;
          '';
        };
      };
      "files.${secondDomain}" = {
        enableACME = true;
        forceSSL = true;
        quic = true;

        locations."/" = {
          proxyPass = mylib.formatMappingHttp proxy-ports.files;
          extraConfig = ''
            client_max_body_size 512m;
          '';
        };
      };
    };
  };
}
