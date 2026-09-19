{
  config,
  proxy-ports,
  unstable,
  mylib,
  ...
}: let
  domain = "photos.${config.networking.domain}";
  dataPath = "/srv/big-storage/immich";
  secretsPath = ../../secrets/immich;
in {
  age.secrets.immich-env.file = "${secretsPath}/env.age";

  services.immich = {
    enable = true;
    openFirewall = true;
    package = unstable.legacyPackages.x86_64-linux.immich;
    settings = {
      newVersionCheck.enabled = true;
    };
    port = proxy-ports.immich.port;
    secretsFile = config.age.secrets.immich-env.path;
    host = "0.0.0.0";
    mediaLocation = dataPath;
    accelerationDevices = ["/dev/dri/renderD128"];
  };

  systemd.tmpfiles.settings."10-immich" = {
    "${dataPath}".d = {
      group = "immich";
      mode = "0755";
      user = "immich";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    quic = true;

    locations."/" = {
      proxyWebsockets = true;
      proxyPass = mylib.formatMappingHttp proxy-ports.immich;
      extraConfig = ''
        client_max_body_size 10G;
      '';
    };
  };
}
