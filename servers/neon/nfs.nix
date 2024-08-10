{config, ...}: {
  services.nfs = {
    server = {
      enable = true;
      exports = let
        inherit (config.users.users.qbittorrent) uid;
        inherit (config.users.groups.qbittorrent) gid;
      in ''
        /srv/torrents 192.168.178.0/24(no_subtree_check,rw,all_squash,anonuid=${builtins.toString uid},anongid=${builtins.toString gid})
      '';
    };
    settings.nfsd = {
      UDP = false;
      vers2 = false;
      vers3 = false;
    };
  };

  networking.firewall.allowedTCPPorts = [2049];

  systemd.tmpfiles.settings."10-nfs"."/srv/torrents".d = {
    mode = "755";
    user = "qbittorrent";
    group = "qbittorrent";
  };
}
