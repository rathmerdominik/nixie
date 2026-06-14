{
  pkgs,
  attrName,
  storageBoxUser,
  ...
}: let
  device = "${storageBoxUser}@${storageBoxUser}.your-storagebox.de:/home/storage/${attrName}";

  mountBox = {
    path,
    user,
  }: let
    mountPoint = "/srv/big-storage/${path}";
  in {
    description = "sshfs mount of storage box at ${mountPoint}";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "forking";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";
      ExecStart = pkgs.writeShellScript "mount-bigstorage-${path}" ''
        set -eu
        uid=$(${pkgs.coreutils}/bin/id -u ${user})
        gid=$(${pkgs.coreutils}/bin/id -g ${user})
        exec ${pkgs.sshfs}/bin/sshfs \
          ${device}/${path} \
          ${mountPoint} \
          -o rw,noatime,allow_other,_netdev,uid=$uid,gid=$gid,IdentityFile=/etc/ssh/ssh_host_ed25519_key,Port=23
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -u ${mountPoint}";
      RemainAfterExit = true;
    };
  };
in {
  systemd.services = {
    "bigstorage-immich" = mountBox {
      path = "immich";
      user = "immich";
    };
    "bigstorage-pelican" = mountBox {
      path = "pelican";
      user = "root";
    };
    "bigstorage-filebrowser" = mountBox {
      path = "filebrowser";
      user = "filebrowser";
    };
    "bigstorage-syncthing" = mountBox {
      path = "syncthing";
      user = "syncthing";
    };
    "bigstorage-paperless" = mountBox {
      path = "paperless";
      user = "paperless";
    };
  };

  systemd.tmpfiles.settings."10-sshfs" = {
    "/srv/big-storage".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };
}
