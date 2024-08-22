{
  config,
  pkgs,
  lib,
  ...
}: {
  age.secrets.pterodactyl-env.file = ../../secrets/pterodactyl-env.age;

  virtualisation.oci-containers.containers.pterodactyl = {
    image = "ghcr.io/pterodactyl/panel:latest";
    ports = [
      "9393:80"
      "9494:443"
    ];
    volumes = [
      "/var/lib/pterodactyl/var/:/app/var/"
      "/var/log/pterodactyl/:/app/storage/logs"
    ];
    environment = {
      APP_TIMEZONE = "Europe/Berlin";
      APP_URL = "https://panel.hammerclock.net";
      APP_SERVICE_AUTHOR = "der@hammerclock.net";
      APP_ENV = "production";
      APP_ENVIRONMENT_ONLY = "false";

      CACHE_DRIVER = "redis";
      SESSION_DRIVER = "redis";
      QUEUE_DRIVER = "redis";
      REDIS_HOST = "cache";

      DB_HOST = "database";
      DB_DATABASE = "panel";
      DB_USERNAME = "pterodactyl";
      DB_PORT = "3306";
    };
    environmentFiles = [
      config.age.secrets.pterodactyl-env.path
    ];
    extraOptions = [
      "--network=panel0"
    ];
  };

  systemd.services.init-panel0-network = {
    description = "Create the network bridge for pterodactyl.";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      check=$(${lib.getExe pkgs.docker} network ls | grep panel0 || true)
      if [ -z "$check" ]; then
        ${lib.getExe pkgs.docker} network create \
          --subnet 172.21.0.0/16 \
          --driver bridge \
          --opt com.docker.network.bridge.name=panel0 \
          panel0
      else
        echo "panel0 already exists in docker"
      fi
    '';
  };

  virtualisation.oci-containers.containers.database = {
    image = "docker.io/mariadb:10.5";
    cmd = ["--default-authentication-plugin=mysql_native_password"];
    volumes = [
      "/var/lib/pterodactyl/database:/var/lib/mysql"
    ];
    environmentFiles = [
      config.age.secrets.pterodactyl-env.path
    ];
    extraOptions = [
      "--network=panel0"
    ];
  };

  virtualisation.oci-containers.containers.cache = {
    image = "docker.io/library/redis:alpine";
    extraOptions = [
      "--network=panel0"
    ];
  };

  systemd.tmpfiles.settings."10-pterodactyl" = {
    "/var/log/pterodactyl".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "/var/lib/pterodactyl/var".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "/var/lib/pterodactyl/database".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };
}
