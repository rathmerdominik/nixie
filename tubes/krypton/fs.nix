{
  attrName,
  storageBoxUser,
  ...
}: {
  fileSystems."/srv/big-storage" = {
    device = "${storageBoxUser}@${storageBoxUser}.your-storagebox.de:/${attrName}";
    fsType = "sshfs";
    options = [
      "nodev"
      "noatime"
      "allow_other"
      "IdentityFile=/etc/ssh/ssh_host_ed25519_key"
    ];
  };
}
