{
  mylib,
  proxy-ports,
  config,
  ...
}: let
  domain = "files.${config.networking.domain}";
  rootPath = "/srv/big-storage/filebrowser";
  dataPath = "${rootPath}/data";
in {
  services.filebrowser = {
    enable = true;
    settings = {
      root = dataPath;
      address = "0.0.0.0";
      port = proxy-ports.files.port;
    };
  };

  systemd.tmpfiles.settings."10-filebrowser" = {
    filebrowserPath.d = {
      group = "filebrowser";
      mode = "0755";
      user = "filebrowser";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    quic = true;

    locations."/" = {
      proxyPass = mylib.formatMappingHttp proxy-ports.files;
      extraConfig = ''
        client_max_body_size 512m;
      '';
    };
  };
}
