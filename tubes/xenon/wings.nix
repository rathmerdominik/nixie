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
      "-t"
    ];
  };

  networking.firewall.allowedTCPPorts = [2022 25565 25566 34197];

  systemd.tmpfiles.settings."10-pterodactyl" = {
    "/srv/disks/mass-storage/Pterodactyl".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "/srv/disks/mass-storage/Pterodactyl/backups".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
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
