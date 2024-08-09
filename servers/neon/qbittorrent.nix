{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.qbittorrent-nox
  ];

  systemd.user.services."qbittorrent-nox@qbittorrent".wantedBy = ["default.target"];

  users = {
    users.qbittorrent = {
      isSystemUser = true;
      group = "qbittorrent";
      home = "/var/lib/qbittorrent";
    };
    groups.qbittorrent = {};
  };

  systemd.tmpfiles.settings."10-qbittorrent"."/var/lib/qbittorrent/.config/qBittorrent/qBittorrent.conf".f = {
    mode = "755";
    user = "qbittorrent";
    group = "root";
    argument = ''
      [BitTorrent]
      Session\Interface=wg-mullvad
      Session\InterfaceName=wg-mullvad
    '';
  };
}
