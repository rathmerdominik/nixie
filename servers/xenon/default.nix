{
  inputs,
  config,
  ...
}: {
  imports =
    (map (n: ./${n}) (builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./.))))
    ++ [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
      inputs.hardware.nixosModules.common-pc-ssd
    ];
  nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    extraModulePackages = with config.boot.kernelPackages;
      if beta
      then [nvidia_x11_beta]
      else [nvidia_x11];

    kernelParams = ["nvidia-drm.fbdev=1"];
    initrd.kernelModules = ["nvidia"];
  };

  system.stateVersion = "24.11";

  powerManagement.cpuFreqGovernor = "performance";

  virtualisation.oci-containers.backend = "docker";

  networking = {
    firewall.enable = false;
    domain = "hammerclock.net";
  };

  inputs.hardware.nvidia-container-toolkit.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;

      open = false;

      package = with config.boot.kernelPackages;
        if beta
        then nvidiaPackages.beta
        else nvidiaPackages.latest;
    };
  };
}
