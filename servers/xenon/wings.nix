{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config.networking) domain;
in {
  virtualisation.oci-containers.containers.wings = {
    image = "ghcr.io/pterodactyl/wings:latest";
    ports = [
      "9595:443"
      "2022:2022"
    ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/var/lib/docker/containers/:/var/lib/docker/containers/"
      "/etc/pterodactyl/:/etc/pterodactyl/"
      "/srv/disks/wings-drive/pterodactyl/:/var/lib/pterodactyl/"
      "/var/log/pterodactyl/:/var/log/pterodactyl/"
      "/tmp/pterodactyl/:/tmp/pterodactyl/"
      "/etc/ssl/certs/ca-certificates.crt:/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt:ro"
    ];
    environment = {
      TZ = "GMT";
      WINGS_UID = "988";
      WINGS_GID = "988";
      WINGS_USERNAME = "pterodactyl";
    };
    extraOptions = [
      "--network=wings0"
      "-t"
    ];
  };

  systemd.services.init-wings0-network = {
    description = "Create the network bridge for wings.";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      check=$(${lib.getExe pkgs.docker} network ls | grep wings0 || true)
      if [ -z "$check" ]; then
        ${lib.getExe pkgs.docker} network create \
          --subnet 172.21.0.0/16 \
          --driver bridge \
          --opt com.docker.network.bridge.name=wings0 \
          wings0
      else
        echo "wings0 already exists in docker"
      fi
    '';
  };

  services.nginx.virtualHosts = {
    "wings.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."~ ^\/api\/servers\/(?<serverid>.*)?\/ws$" = {
        proxyWebsockets = true;
        proxyPass = "http://localhost:9595/api/servers/$serverid/ws";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
          client_max_body_size 1024m;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_redirect off;
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };

      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://localhost:9595";
        extraConfig = ''
          proxy_redirect off;
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [2022 9595 25565];

  systemd.tmpfiles.settings."10-pterodactyl" = {
    "/var/log/pterodactyl".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "/var/lib/pterodactyl".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "/etc/pterodactyl".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "/tmp/pterodactyl".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };
}
