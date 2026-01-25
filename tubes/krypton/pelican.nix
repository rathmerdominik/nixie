{
  config,
  pkgs,
  lib,
  ...
}: {
  age.secrets.pelican-env.file = ../../secrets/pelican-env.age;

  virtualisation.oci-containers.containers.pelican = {
    image = "ghcr.io/pelican-dev/panel:latest";
    ports = [
      "9393:80"
    ];
    volumes = [
      "/var/lib/pelican:/pelican-data"
      "/var/log/pelican:/var/www/html/storage/logs"
    ];
    environment = {
      APP_TIMEZONE = "Europe/Berlin";
      APP_URL = "https://panel.hammerclock.net";
      APP_SERVICE_AUTHOR = "der@hammerclock.net";
      APP_ENV = "production";
      APP_ENVIRONMENT_ONLY = "false";
      XDG_DATA_HOME = "/pelican-data";
      BEHIND_PROXY = "true";

      CACHE_STORE = "redis";
      SESSION_DRIVER = "redis";
      QUEUE_CONNECTION = "redis";
      REDIS_HOST = "cache";

      DB_CONNECTION = "mariadb";
      DB_HOST = "database";
      DB_DATABASE = "panel";
      DB_USERNAME = "pelican";
      DB_PORT = "3306";

      TRUSTED_PROXIES = "10.147.18.13/24";
    };
    environmentFiles = [
      config.age.secrets.pelican-env.path
    ];
    extraOptions = [
      "--pull=always"
      "--network=panel0"
    ];
  };

  systemd.services.init-panel0-network = {
    description = "Create the network bridge for pelican.";
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
          --ipv6=false \
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
      "/var/lib/pelican/database:/var/lib/mysql"
    ];
    environmentFiles = [
      config.age.secrets.pelican-env.path
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

  # The cool people at Pelican thought that it would be funny to have www-data write everywhere
  # So yeah... i just create a mock user so that the uid and guid are locked
  users = {
    groups."www-data" = {
      gid = 82;
    };
    users."www-data" = {
      isSystemUser = true;
      group = "www-data";
      uid = 82;
    };
  };

  systemd.tmpfiles.settings."10-pelican" = {
    "/var/log/pelican".d = {
      group = "www-data";
      mode = "0755";
      user = "www-data";
    };
    "/var/log/pelican/supervisord".d = {
      group = "www-data";
      mode = "0755";
      user = "www-data";
    };
    "/var/lib/pelican".d = {
      group = "www-data";
      mode = "0755";
      user = "www-data";
    };
    "/var/lib/pelican/database".d = {
      group = "www-data";
      mode = "0755";
      user = "www-data";
    };
  };
}
