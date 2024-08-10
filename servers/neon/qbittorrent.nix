{
  lib,
  pkgs,
  ...
}: {
  systemd.services.qbittorrent = {
    description = "qBittorrent-nox service";
    documentation = ["man:qbittorrent-nox(1)"];
    wants = ["network-online.target"];

    script = lib.getExe' pkgs.qbittorrent-nox "qbittorrent-nox";

    serviceConfig = {
      Type = "simple";
      PrivateTmp = false;
      User = "qbittorrent";
      Group = "qbittorrent";
      TimeoutStopSec = 1800;
    };

    wantedBy = ["multi-user.target"];
  };

  networking.firewall.allowedTCPPorts = [8080];

  users = {
    users.qbittorrent = {
      uid = 996;
      isSystemUser = true;
      group = "qbittorrent";
      home = "/var/lib/qbittorrent";
      createHome = true;
    };
    groups.qbittorrent = {
      gid = 996;
    };
  };
}
