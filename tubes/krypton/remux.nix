{
  lib,
  pkgs,
  mylib,
  proxy-ports,
  primary-domain,
  ...
}: {
  virtualisation.oci-containers.containers.remux = {
    image = "ghcr.io/lostb1t/remux:latest";
    pull = "always";
    ports = ["6769:3000"];
    volumes = ["/var/lib/remux:/data"];
    networks = ["remux"];
    extraOptions = [
      "--ip=172.22.0.2"
    ];
  };

  systemd.tmpfiles.settings."10-remux" = {
    "/var/lib/remux".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };

  systemd.services.init-remux-network = {
    description = "Create the network bridge for pelican.";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      check=$(${lib.getExe pkgs.docker} network ls | grep remux || true)
      if [ -z "$check" ]; then
        ${lib.getExe pkgs.docker} network create \
          --subnet 172.22.0.0/16 \
          --driver bridge \
          --opt com.docker.network.bridge.name=remux \
          --ipv6=false \
          remux
      else
        echo "remux already exists in docker"
      fi
    '';
  };

  services.nginx.virtualHosts."movies.${primary-domain}" = {
    enableACME = true;
    forceSSL = true;
    quic = true;

    locations."/" = {
      proxyPass = mylib.formatMappingHttp proxy-ports.remux;
    };
  };
}
