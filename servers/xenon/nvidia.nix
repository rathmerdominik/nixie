{
  config,
  pkgs,
  ...
}: {
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

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  environment.systemPackages = [pkgs.nvidia-container-toolkit];

  hardware.nvidia-container-toolkit.enable = true;
}
