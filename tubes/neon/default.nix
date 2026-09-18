{
  inputs,
  lib,
  pkgs,
  ...
}: let
  ignoredFiles = lib.fileset.unions [./default.nix];
in {
  imports =
    lib.fileset.toList (lib.fileset.difference ./. ignoredFiles)
    ++ [
      "${inputs.nixos-hardware}/raspberry-pi/4"
    ];

  powerManagement.cpuFreqGovernor = "ondemand";

  hardware.enableAllFirmware = true;

  boot = {
    kernelPackages = pkgs.linuxPackages;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "26.05";
}
