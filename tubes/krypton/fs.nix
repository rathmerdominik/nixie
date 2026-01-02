{
  attrName,
  storageBoxUser,
  ...
}: {
  fileSystems."/srv/big-storage" = {
    device = "${storageBoxUser}@${storageBoxUser}.your-storagebox.de:/home/storage/${attrName}";
    fsType = "sshfs";
    options = [
      "nodev"
      "noatime"
      "allow_other"
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
