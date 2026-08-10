{
  lib,
  pkgs,
  ...
}: let
  ignoredFiles = lib.fileset.unions [./default.nix ./packages];
in {
  imports = lib.fileset.toList (lib.fileset.difference ./. ignoredFiles);

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.loader.timeout = 0;
  hardware.cpu.amd.updateMicrocode = true;

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11";

  powerManagement.cpuFreqGovernor = "performance";

  networking.networkmanager.enable = true;
  networking.interfaces.enp4s0.wakeOnLan.enable = true;
  networking.firewall.allowedUDPPorts = [9];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
