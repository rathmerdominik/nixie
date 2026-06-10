{
  attrName,
  storageBoxUser,
  ...
}: {
  fileSystems."/srv/big-storage" = {
    device = "${storageBoxUser}@${storageBoxUser}.your-storagebox.de:/home/storage/${attrName}";
    fsType = "sshfs";
    options = [
      "rw"
      "noatime"
      "allow_other"
      "_netdev"
      "uid=0"
      "gid=0"
      "x-systemd.automount"
      "IdentityFile=/etc/ssh/ssh_host_ed25519_key"
      "Port=23"
    ];
  };

  systemd.tmpfiles.settings."10-sshfs" = {
    "/srv/big-storage".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };
}
