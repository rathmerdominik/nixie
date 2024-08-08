{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.mergerfs
  ];

  fileSystems = let
    mkMergerfs = device: {
      inherit device;
      fsType = "fuse.mergerfs";
      options = ["allow_other" "moveonenospc=true" "dropcacheonclose=true" "posix_acl=true" "category.create=mfs"];
    };
    mkDisk = label: {
      inherit label;
      fsType = "ext4";
      options = ["rw" "relatime"];
    };
  in {
    "/srv/disks/big-storage" = mkDisk "big_storage";
    "/srv/disks/big-backup" = mkDisk "big_backup";
    "/srv/disks/medium-storage" = mkDisk "medium_storage";
    "/srv/disks/medium-backup" = mkDisk "medium_backup";
    "/srv/disks/small-roms-1" = mkDisk "small_roms_1";
    "/srv/disks/small-roms-2" = mkDisk "small_roms_2";

    "/srv/mergerfs/storage" = mkMergerfs "/srv/disks/big-storage:/srv/disks/medium-storage";
    "/srv/mergerfs/backup" = mkMergerfs "/srv/disks/big-backup:/srv/disks/medium-backup";
    "/srv/mergerfs/roms" = mkMergerfs "/srv/disks/small-roms-1:/srv/disks/small-roms-2";
  };
}
