{
  lib,
  pkgs,
  ...
}: let
  ignoredFiles = lib.fileset.unions [./default.nix ./packages];
in {
  imports = lib.fileset.toList (lib.fileset.difference ./. ignoredFiles);

  hardware.cpu.amd.updateMicrocode = true;

  powerManagement.cpuFreqGovernor = "performance";

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  networking = {
    networkmanager.enable = true;
    interfaces.enp4s0.wakeOnLan.enable = true;
    firewall.allowedUDPPorts = [9];
  };
  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    loader.timeout = 0;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11";
}
