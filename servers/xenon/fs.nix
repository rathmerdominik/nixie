{}: {
  fileSystems = let
    mkDisk = label: {
      inherit label;
      fsType = "ext4";
      options = ["rw" "relatime"];
    };
  in {
    systemd.tmpfiles.settings."10-pterodactyl" = {
      "/srv/pterodactyl".d = {
        group = "root";
        mode = "0755";
        user = "root";
      };
      "/srv/pterodactyl/backups".d = {
        group = "root";
        mode = "0755";
        user = "root";
      };
    };

    "/srv/disks/eight-one" = mkDisk "small_roms_1";
    "/srv/disks/eight-two" = mkDisk "small_roms_2";

    "/var/lib/pterodactyl" = mkDisk "wings_drive";

    "/srv/pterodactyl/backups" = {
      device = "/srv/disks/wings-drive/pterodactyl/backups";
      options = ["bind"];
    };
  };
}
