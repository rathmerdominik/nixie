{
  attrName,
  config,
  pkgs,
  ...
}: let
  secretsPath = ../../secrets/restic;
in {
  age.secrets."restic-${attrName}".file = "${secretsPath}/${attrName}.age";

  services.restic.backups.${attrName} = {
    repositoryFile = pkgs.writeText "restic-repository" ''
      sftp:$(cat ${config.age.secrets."storage-user".path})@$(cat ${config.age.secrets."storage-user".path}).your-storagebox.de:/${attrName}
    '';
    initialize = true;
    paths = [
      config.services.vaultwarden.backupDir
      config.services.syncthing.dataDir
      config.services.immich.mediaLocation
      config.services.paperless.dataDir
      config.services.filebrowser.settings.root
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
