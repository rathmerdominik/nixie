{...}: {
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
      "/srv/big-storage/pterodactyl/backup/:/var/lib/pterodactyl/backup/"
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
    };
    extraOptions = [
      "-t"
    ];
  };

  networking.firewall.allowedTCPPorts = [2022 25565];

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
    "/srv/big-storage/pterodactyl/backup/".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };
}
