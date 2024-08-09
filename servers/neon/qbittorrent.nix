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

  users = {
    users.qbittorrent = {
      isSystemUser = true;
      group = "qbittorrent";
      home = "/var/lib/qbittorrent";
      createHome = true;
    };
    groups.qbittorrent = {};
  };

  systemd.tmpfiles.settings."10-qbittorrent" = {
    "/var/lib/qbittorrent/.config/qBittorrent/qBittorrent.conf".d = {
      mode = "755";
      user = "qbittorrent";
      group = "qbittorrent";
    };
    "/var/lib/qbittorrent/.config/qBittorrent/qBittorrent.conf".C = {
      mode = "644";
      user = "qbittorrent";
      group = "qbittorrent";
      argument = builtins.toFile "qBittorrent.conf" ''
        [BitTorrent]
        Session\Interface=wg0-mullvad
        Session\InterfaceName=wg0-mullvad
      '';
    };
  };
}
