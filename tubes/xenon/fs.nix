{...}: {
  systemd.tmpfiles.settings."10-pterodactyl" = {
    "/srv/disks/mass-storage/Pterodactyl".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
    "/srv/disks/mass-storage/Pterodactyl/backups".d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };

  fileSystems = let
    mkDisk = label: {
      inherit label;
      fsType = "ext4";
      options = ["rw" "relatime"];
    };
  in {
    "/srv/disks/mass-storage" = mkDisk "mass-storage";
    "/srv/disks/mass-backup" = mkDisk "mass-backup";

    "/var/lib/pterodactyl" = mkDisk "wings_drive";

    "/srv/disks/mass-storage/Pterodactyl/backups" = {
      device = "/srv/disks/wings-drive/pterodactyl/backups";
      options = ["bind"];
    };
  };
}
