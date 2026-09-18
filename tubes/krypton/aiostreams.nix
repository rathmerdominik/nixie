{config, ...}: let
  secretsPath = ../../secrets/aiostreams;
  dataPath = "/var/lib/aiostreams";
  port = 3002;
  tag = "nightly"; # Officially recommended by the AIOStreams devs
in {
  age.secrets.aiostreams-env.file = "${secretsPath}/env.age";

  systemd.tmpfiles.rules = [
    "d ${dataPath} 0755 root root -"
  ];

  virtualisation.oci-containers.containers.aiostreams = {
    image = "ghcr.io/viren070/aiostreams:${tag}";
    ports = ["${toString port}:3000"];
    pull = "always";
    networks = ["remux"];

    environment = {
      BASE_URL = "http://172.22.0.3:3000";
      # PORT = "3000"; # This is really funny... AIOStreams offers a PORT env variable, but it does not pass it to apps requesting streams. Literally has to be merged to the baseurl...
      DATABASE_URI = "sqlite:///app/data/db.sqlite";
      NODE_OPTIONS = "--dns-result-order=ipv4first";
    };
    environmentFiles = [
      config.age.secrets.aiostreams-env.path
    ];
    volumes = ["${dataPath}:/app/data"];
    extraOptions = [
      "--dns=1.1.1.1"
      "--dns=8.8.8.8"
      "--ip=172.22.0.3"
    ];
  };

  virtualisation.oci-containers.containers.warp = {
    image = "caomingjun/warp:latest";
    pull = "always";
    networks = ["remux"];

    capabilities = {
      MKNOD = true;
      NET_ADMIN = true;
      AUDIT_WRITE = true;
    };

    extraOptions = [
      "--ip=172.22.0.1"
    ];
  };

  systemd.tmpfiles.settings."10-aiostreams" = {
    "${dataPath}".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };
}
