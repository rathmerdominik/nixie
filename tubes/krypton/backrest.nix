{pkgs, ...}: {
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
}
