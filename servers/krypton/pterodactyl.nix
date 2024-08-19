{
  config,
  pkgs,
  ...
}: {
  age.secrets.pterodactyl-env.file = ../../secrets/pterodactyl-env.age;
  age.secrets.pterodactyl-sql.file = ../../secrets/pterodactyl-sql.age;

  virtualisation.oci-containers.containers.pterodactyl = {
    image = "ghcr.io/pterodactyl/panel:latest";
    ports = [
      "9595:80"
      "9696:443"
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
      REDIS_HOST = "127.0.0.1";
      REDIS_PORT = "6379";

      DB_HOST = "host.docker.internal";
      DB_DATABASE = "panel";
      DB_USERNAME = "panel";
      DB_PORT = "3306";
    };
    environmentFiles = [
      config.age.secrets.pterodactyl-env.path
    ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        max_connections = 512;
      };
    };
    ensureDatabases = ["panel"];
    ensureUsers = [
      {
        name = "panel";
        ensurePermissions = {
          "panel.*" = "ALL PRIVILEGES";
        };
      }
    ];
    initialScript = config.age.secrets.pterodactyl-sql.path;
  };

  services.redis.servers.panel = {
    enable = true;
    port = 6379;
  };

  services.nginx.virtualHosts = let
    inherit (config.networking) domain;
  in {
    "panel.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."/" = {
        proxyPass = "http://localhost:9595";
      };
    };
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
  };
}
