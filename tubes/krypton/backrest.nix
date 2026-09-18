{
  pkgs,
  mylib,
  config,
  proxy-ports,
  ...
}: let
  domain = "backup.${config.networking.domain}";
  rootPath = "/var/lib/backrest";
  configPath = "${rootPath}/config";
  dataPath = "${rootPath}/data";
in {
  systemd.services.backrest = {
    description = "Restic GUI";
    path = [
      pkgs.bash
      pkgs.curl
      pkgs.coreutils
      pkgs.restic
      pkgs.backrest
    ];

    environment = {
      BACKREST_PORT = "0.0.0.0:${toString proxy-ports.backrest.port}";
      BACKREST_RESTIC_COMMAND = "${pkgs.restic}/bin/restic";
      BACKREST_CONFIG = configPath;
      BACKREST_DATA = dataPath;
    };

    serviceConfig = {
      ExecStart = "${pkgs.backrest}/bin/backrest";
      Restart = "on-failure";
      RestartSec = "5";
    };
    wantedBy = ["multi-user.target"];
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = mylib.formatMappingHttp proxy-ports.backrest;
      extraConfig = ''
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
        proxy_buffering off;
      '';
    };
  };
}
