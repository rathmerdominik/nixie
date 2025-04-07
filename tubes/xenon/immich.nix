{
  config,
  lib,
  pkgs,
  proxy-ports,
  ...
}: let
  immich-path = "/var/lib/immich";
  immich-version = "v1.131.3";
in {
  # TODO Wohoo they made a module. Will have to transition at some point. Will be painful because of postgres.
  age.secrets.immich.file = ../../secrets/immich.age;

  virtualisation.oci-containers.containers."immich-server" = {
    image = "ghcr.io/immich-app/immich-server:${immich-version}";
    environment = {
      TZ = "Europe/Berlin";
    };
    environmentFiles = [
      config.age.secrets.immich.path
    ];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "${immich-path}/upload:/usr/src/app/upload:rw"
      "${immich-path}/geocoding:/usr/src/app/geocoding"
      "${immich-path}/photos:/usr/src/app/upload/library"
    ];
    ports = [
      "${builtins.toString proxy-ports.immich.port}:2283"
    ];
    dependsOn = [
      "immich-postgres"
      "immich-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network=immich"
      "--network-alias=immich-server"
      "--device=/dev/dri:/dev/dri"
      "--pull=always"
    ];
  };

  virtualisation.oci-containers.containers."immich-machine-learning" = {
    image = "ghcr.io/immich-app/immich-machine-learning:${immich-version}-cuda";
    environment = {
      TZ = "Europe/Berlin";
    };
    environmentFiles = [
      config.age.secrets.immich.path
    ];
    volumes = [
      "${immich-path}/cache:/cache:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network=immich"
      "--network-alias=immich-machine-learning"
      "--device=nvidia.com/gpu=all"
      "--pull=always"
    ];
  };

  virtualisation.oci-containers.containers."immich-postgres" = {
    image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
    environment = {
      POSTGRES_INITDB_ARGS = "--data-checksums";
    };
    environmentFiles = [
      config.age.secrets.immich.path
    ];
    volumes = [
      "${immich-path}/postgres:/var/lib/postgresql/data:rw"
    ];
    cmd = ["postgres" "-c" "shared_preload_libraries=vectors.so" "-c" "search_path=\"$user\", public, vectors" "-c" "logging_collector=on" "-c" "max_wal_size=2GB" "-c" "shared_buffers=512MB" "-c" "wal_compression=on"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready --dbname='immich' --username='postgres' || exit 1; Chksum=\"$(psql --dbname='immich' --username='postgres' --tuples-only --no-align --command='SELECT COALESCE(SUM(checksum_failures), 0) FROM pg_stat_database')\"; echo \"checksum failure count is $Chksum\"; [ \"$Chksum\" = '0' ] || exit 1"
      "--health-interval=5m0s"
      "--health-start-period=5m0s"
      "--network-alias=database"
      "--network=immich"
      "--pull=always"
    ];
  };

  virtualisation.oci-containers.containers."immich-redis" = {
    image = "docker.io/redis:6.2-alpine@sha256:e3b17ba9479deec4b7d1eeec1548a253acc5374d68d3b27937fcfe4df8d18c7e";
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=redis-cli ping || exit 1"
      "--network-alias=redis"
      "--network=immich"
      "--pull=always"
    ];
  };

  systemd.services.init-immich-network = {
    description = "Create the network bridge for immich.";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      check=$(${lib.getExe pkgs.docker} network ls | grep immich || true)
      if [ -z "$check" ]; then
        ${lib.getExe pkgs.docker} network create \
          --driver bridge \
          --opt com.docker.network.bridge.name=immich \
          immich
      else
        echo "immich already exists in docker"
      fi
    '';
  };

  systemd.tmpfiles.settings."10-immich" = {
    "${immich-path}/upload".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "${immich-path}/geocoding".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "${immich-path}/photos".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "${immich-path}/postgres".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };
}
