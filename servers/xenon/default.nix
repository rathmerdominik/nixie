{
  inputs,
  config,
  pkgs,
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
    initrd.kernelModules = ["nvidia"];
  };

  system.stateVersion = "24.11";

  powerManagement.cpuFreqGovernor = "performance";

  virtualisation.oci-containers.backend = "docker";

  networking = {
    firewall.enable = false;
    domain = "hammerclock.net";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;

      open = false;

      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    nvidia-container-toolkit.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nvitop
  ];
}
