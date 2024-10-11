{
  inputs,
  lib,
  ...
}: {
  imports =
    lib.fileset.toList (lib.fileset.difference ./. ./default.nix)
    ++ [
      inputs.hardware.nixosModules.common-cpu-intel
      inputs.hardware.nixosModules.common-gpu-intel
      inputs.hardware.nixosModules.common-pc-ssd
    ];

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "24.11";

  networking.firewall.checkReversePath = "loose";
  networking.wireguard.enable = true;

  powerManagement.cpuFreqGovernor = "performance";
}
