{
  services.nfs.server = {
    enable = true;
    exports = ''
      /srv/torrents     192.168.178.0(no_subtree_check,rw,all_squash,anonuid=0,anongid=0)
    '';
    extraNfsdConfig = ''
      UDP=off
      vers2=off
      vers3=off
    '';
  };

  systemd.tmpfiles.settings."10-nfs"."/srv/torrents".d = {
    mode = "755";
    user = "qbittorrent";
    group = "nogroup";
  };
}
