{
  boot.tmp.cleanOnBoot = true;

  fileSystems = {
    "/" = {
      fsType = "ext4";
      options = ["noatime"];
    };
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
  };
}
