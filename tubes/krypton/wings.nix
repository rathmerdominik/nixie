{
  mylib,
  primary-domain,
  proxy-ports,
  ...
}: {
  virtualisation.oci-containers.containers.wings = {
    image = "ghcr.io/pelican-dev/wings:latest";
    ports = [
      "9595:8080"
      "2022:2022"
    ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/var/lib/docker/containers/:/var/lib/docker/containers/"
      "/etc/pelican/:/etc/pelican/"
      "/srv/big-storage/pelican/backups/:/var/lib/pelican/backups/"
      "/var/lib/pelican/:/var/lib/pelican/"
      "/var/log/pelican/:/var/log/pelican/"
      "/tmp/pelican/:/tmp/pelican/"
    ];
    environment = {
      TZ = "UTC";
      WINGS_UID = "988";
      WINGS_GID = "988";
      WINGS_USERNAME = "pelican";
    };
    extraOptions = [
      "-t"
    ];
  };

  networking.firewall.allowedTCPPorts = [2022 25565 27960];

  systemd.tmpfiles.settings."10-pelican" = {
    "/etc/pelican".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "/tmp/pelican".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "/srv/big-storage/pelican/backups/".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };

  services.nginx.virtualHosts."wings.${primary-domain}" = {
    enableACME = true;
    forceSSL = true;
    quic = true;

    locations."~ ^\/api\/servers\/(?<serverid>.*)?\/ws$" = {
      proxyWebsockets = true;
      proxyPass = "${mylib.formatMappingHttp proxy-ports.wings}/api/servers/$serverid/ws";
      extraConfig = ''
        proxy_buffering off;
        proxy_request_buffering off;
      '';
    };

    locations."/" = {
      proxyWebsockets = true;
      proxyPass = mylib.formatMappingHttp proxy-ports.wings;
      extraConfig = ''
        proxy_buffering off;
        proxy_request_buffering off;
        client_max_body_size 1024m;
      '';
    };
  };
}
