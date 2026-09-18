{lib, ...}: {
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkForce true;
  boot.initrd.availableKernelModules = [
    "vc4"
    "bcm2835_dma"
    "i2c_bcm2835"
    "sun4i_drm"
    "sun8i_drm_hdmi"
    "sun8i_mixer"
  ];
}
