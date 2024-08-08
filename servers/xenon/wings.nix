{
  lib,
  pkgs,
  config,
  ...
}: {
  virtualisation.oci-containers.containers.wings = {
    image = "ghcr.io/pterodactyl/wings:develop";
    ports = [
      "9595:8080"
      "2022:2022"
    ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/var/lib/docker/containers/:/var/lib/docker/containers/"
      "/etc/pterodactyl/:/etc/pterodactyl/"
      "/var/lib/pterodactyl/:/var/lib/pterodactyl/"
      "/var/log/pterodactyl/:/var/log/pterodactyl/"
      "/tmp/pterodactyl/:/tmp/pterodactyl/"
      "/etc/ssl/certs:/etc/ssl/certs:ro"
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
      check=$(${lib.getExe pkgs.podman} network ls | grep wings0 || true)
      if [ -z "$check" ]; then
        ${lib.getExe pkgs.podman} network create \
          --subnet 172.21.0.0/16 \
          --driver bridge \
          --opt com.docker.network.bridge.name=wings0 \
          wings0
      else
        echo "wings0 already exists in podman"
      fi
    '';
  };

  services.nginx.virtualHosts = let
    inherit (config.networking) domain;
  in {
    "wings.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."/" = {
        proxyPass = "http://localhost:9595";
        extraConfig = ''
          proxy_redirect off;
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [2022];

  virtualisation.podman.dockerSocket.enable = true;
}
