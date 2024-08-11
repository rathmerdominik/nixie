{config, ...}: let
  inherit (config.networking) domain;
in {
  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/ajnart/homarr:latest";
    ports = [
      "7575:7575"
    ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/var/lib/homarr/configs:/app/data/configs"
      "/var/lib/homarr/icons:/app/public/icons"
      "/var/lib/homarr/data:/data"
    ];
  };

  services.nginx.virtualHosts = {
    "homarr.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://localhost:7575";
      };
    };
  };
}
