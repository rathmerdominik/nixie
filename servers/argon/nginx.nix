{config, ...}: let
  ports = import ../../proxyports.nix;
  inherit (config.networking) domain;
in {
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
    "bitwarden".${domain} = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://${ports.vaultwarden}";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
