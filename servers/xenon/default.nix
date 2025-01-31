{
  inputs,
  lib,
  ...
}: let
  ignoredFiles = lib.fileset.unions [./default.nix];
in {
  imports =
    lib.fileset.toList (lib.fileset.difference ./. ignoredFiles)
    ++ [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
      inputs.hardware.nixosModules.common-pc-ssd
    ];
  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "24.11";

  powerManagement.cpuFreqGovernor = "performance";

  virtualisation.oci-containers.backend = "docker";

  networking = {
    firewall.enable = false;
    domain = "hammerclock.net";
  };
}
