{
  attrName,
  config,
  storageBoxUser,
  ...
}: let
  immichPhotoPath = "/var/lib/immich/photos";
in {
  age.secrets."restic-${attrName}".file = ../../secrets/restic-${attrName}.age;

  services.restic.backups.${attrName} = {
    repository = "sftp:${storageBoxUser}@${storageBoxUser}.your-storagebox.de:/${attrName}";
    initialize = true;
    paths = [
      config.services.syncthing.dataDir
      immichPhotoPath
    ];
    passwordFile = config.age.secrets."restic-${attrName}".path;
    pruneOpts = ["--keep-daily 7" "--keep-weekly 5" "--keep-monthly 12"];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
    };

    extraOptions = ["sftp.args='-i /etc/ssh/ssh_host_ed25519_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"];
  };
}
