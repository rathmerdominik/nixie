{
  pkgs,
  mylib,
  primary-domain,
  proxy-ports,
  ...
}: {
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
      BACKREST_PORT = "0.0.0.0:9898";
      BACKREST_RESTIC_COMMAND = "${pkgs.restic}/bin/restic";
      BACKREST_CONFIG = "/var/lib/backrest/config";
      BACKREST_DATA = "/var/lib/backrest/data";
    };

    serviceConfig = {
      ExecStart = "${pkgs.backrest}/bin/backrest";
      Restart = "on-failure";
      RestartSec = "5";
    };
    wantedBy = ["multi-user.target"];
  };

  services.nginx.virtualHosts."backup.${primary-domain}" = {
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
