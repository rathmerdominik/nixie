{
  modulesPath,
  lib,
  ...
}: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ../../common
  ];

  fileSystems."/".device = lib.mkForce "/dev/disk/by-label/NIXOS_SD";

  boot.zfs.forceImportRoot = false;

  sdImage.compressImage = true;
}
