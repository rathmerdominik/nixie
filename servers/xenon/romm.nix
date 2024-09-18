{config, ...}: let
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
