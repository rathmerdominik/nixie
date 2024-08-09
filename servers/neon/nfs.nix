{
  services.nfs = {
    enable = true;
    exports = ''
      /srv/torrents     192.168.178.0(rw,all_squash,anonuid=0,anongid=0)
    '';
  };

  systemd.tmpfiles.settings."10-nfs"."/srv/torrents".d = {
    mode = 755;
    user = "qbittorrent";
    group = "nogroup";
  };
}
