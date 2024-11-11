{
  config,
  lib,
  ...
}: {
  hardware.graphics = {
    enable = true;
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  services.xserver.displayManager.lightdm.enable = lib.mkForce false;
  services.displayManager.enable = lib.mkForce false;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = false;

    package = config.boot.kernelPackages.nvidiaPackages.beta;

    nvidiaSettings = false;
  };

  hardware.nvidia-container-toolkit.enable = true;
}
