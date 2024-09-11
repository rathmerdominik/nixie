{
  modulesPath,
  lib,
  ...
}: {
  imports =
    lib.fileset.toList (lib.fileset.difference ./. ./default.nix)
    ++ [
      "${modulesPath}/profiles/qemu-guest.nix"
    ];

  boot = {
    initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sr_mod" "virtio_blk"];
    kernelModules = ["kvm-amd"];
    loader = {
      efi = {
        canTouchEfiVariables = false;
      };
      systemd-boot = {
        enable = false;
      };
      grub = {
        enable = true;
        device = "/dev/vda";
      };
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "24.11";

  powerManagement.cpuFreqGovernor = "performance";

  networking = {
    domain = "hammerclock.net";
  };

  security.acme = {
    defaults.email = "security@hammerclock.net";
    acceptTerms = true;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 6 * 1024;
    }
  ];

  networking.firewall.enable = false;

  networking.nat = {
    enable = true;
    internalInterfaces = ["ens3" "ztnfaavftl"];
    externalInterface = "ztnfaavftl";
  };

  networking.nat.forwardPorts = let
    common = {
      destination = "10.147.18.10:25560-25570";
      sourcePort = "25560:25570";
      loopbackIPs = ["198.251.88.245"];
    };
  in [
    (common // {proto = "tcp";})
    (common // {proto = "udp";})
  ];
}
