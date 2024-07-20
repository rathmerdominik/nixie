{
  boot.tmp.cleanOnBoot = true;

  fileSystems = {
    "/" = {
      fsType = "ext4";
      options = ["noatime"];
      device = "/dev/disk/by-label/main";
    };
    "/boot" = {
      fsType = "vfat";
      device = "/dev/disk/by-label/BOOT";
    };
  };
}
