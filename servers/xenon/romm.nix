{
  config,
  lib,
  pkgs,
  ...
}: let
  romm-version = "3.5.1";
  romm-data = "/var/lib/romm";
  rom-directory = "/srv/mergerfs/roms";
in {
  age.secrets.romm.file = ../../secrets/romm.age;

  virtualisation.oci-containers.containers.romm = {
    image = "ghcr.io/rommapp/romm:${romm-version}";
    ports = [
      "9141:8080"
    ];
    volumes = [
      "romm_resources:/romm/resources"
      "romm_redis_data:/redis-data"
      "${rom-directory}:/romm/library"
      "${romm-data}/assets:/romm/assets"
      "${romm-data}/config:/romm/config"
    ];
    environment = {
      DB_HOST = "romm-db";
      DB_NAME = "romm";
      DB_USER = "romm-user";
    };
    environmentFiles = [
      config.age.secrets.romm.path
    ];
    extraOptions = [
      "--pull=always"
      "--network-alias=romm"
      "--network=romm"
    ];
    dependsOn = [
      "romm-db"
    ];
  };

  virtualisation.oci-containers.containers.romm-db = {
    image = "ghcr.io/linuxserver/mariadb:latest";

    volumes = [
      "mysql_data:/var/lib/mysql"
    ];
    environment = {
      MYSQL_DATABASE = "romm";
      MYSQL_USER = "romm-user";
    };
    environmentFiles = [
      config.age.secrets.romm.path
    ];
    extraOptions = [
      "--network-alias=romm-db"
      "--network=romm"
    ];
  };

  systemd.services.init-romm-network = {
    description = "Create the network bridge for romm.";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      check=$(${lib.getExe pkgs.docker} network ls | grep romm || true)
      if [ -z "$check" ]; then
        ${lib.getExe pkgs.docker} network create \
          --driver bridge \
          --opt com.docker.network.bridge.name=romm \
          romm
      else
        echo "romm already exists in docker"
      fi
    '';
  };

  systemd.tmpfiles.settings."10-romm" = {
    "${romm-data}/assets".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "${romm-data}/config".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };
}
