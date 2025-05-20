{...}: {
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
