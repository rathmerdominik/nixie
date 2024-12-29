{}: {
  fileSystems = let
    mkDisk = label: {
      inherit label;
      fsType = "ext4";
      options = ["rw" "relatime"];
    };
  in {
    "/srv/disks/small-roms-1" = mkDisk "small_roms_1";
    "/srv/disks/small-roms-2" = mkDisk "small_roms_2";
    "/var/lib/pterodactyl" = mkDisk "wings_drive";
  };
}
