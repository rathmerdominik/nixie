{config, ...}: {
  hardware.graphics = {
    enable = true;
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

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
