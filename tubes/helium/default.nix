{
  lib,
  pkgs,
  ...
}: let
  ignoredFiles = lib.fileset.unions [./default.nix];
in {
  imports = lib.fileset.toList (lib.fileset.difference ./. ignoredFiles);

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  hardware.cpu.amd.updateMicrocode = true;

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11";

  powerManagement.cpuFreqGovernor = "performance";

  networking.networkmanager.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
}
