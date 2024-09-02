{config, ...}: {
  #NixOS Stable - 24.05 still calls the graphical togable option as "OpenGL"
  hardware.graphics = {
    enable = true;
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = true;

    nvidiaSettings = false;

    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  hardware.nvidia-container-toolkit.enable = true;
}
