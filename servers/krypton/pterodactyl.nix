{
  config,
  pkgs,
  ...
}: {
  age.secrets.pterodactyl-mail.file = ../../secrets/pterodactyl-mail.age;

  virtualisation.oci-containers.containers.pterodactyl = {
    image = "ghcr.io/pterodactyl/panel:latest";
    ports = [
      "9595:80"
      "9696:443"
    ];
    volumes = [
      "/var/lib/pterodactyl/var/:/app/var/"
      "/var/lib/pterodactyl/nginx/:/etc/nginx/http.d/"
      "/var/libpterodactyl/certs/:/etc/letsencrypt/"
      "/var/lib/pterodactyl/logs/:/app/storage/logs"
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
      REDIS_HOST = "localhost:6379";

      DB_PASSWORD = "";
      DB_HOST = "localhost";
      DB_PORT = "3306";
    };
    environmentFiles = [
      config.age.secrets.pterodactyl-mail.path
    ];
  };

  services.mysql = {
    package = pkgs.mariadb;
    enable = true;
    ensureDatabases = [
      "panel"
    ];
    ensureUsers = [
      {
        name = "pterodactyl";
        ensurePermissions = {
          "panel.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.redis = {
    package = pkgs.valkey;
    servers.valkey = {
      port = 6379;
      enable = true;
    };
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
}
