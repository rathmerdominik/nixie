{
  lib,
  pkgs,
  ...
}: {
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
      "/var/lib/pterodactyl/:/var/lib/pterodactyl/"
      "/var/log/pterodactyl/:/var/log/pterodactyl/"
      "/tmp/pterodactyl/:/tmp/pterodactyl/"
      "/etc/ssl/certs/ca-certificates.crt:/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt:ro"
    ];
    environment = {
      TZ = "GMT";
      WINGS_UID = "988";
      WINGS_GID = "988";
      WINGS_USERNAME = "pterodactyl";
      TRUSTED_PROXIES = "10.147.18.11/24";
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

  networking.firewall.allowedTCPPorts = [2022 25565 25566];

  systemd.tmpfiles.settings."10-pterodactyl" = {
    "/var/log/pterodactyl".d = {
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
