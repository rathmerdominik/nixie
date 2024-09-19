{
  modulesPath,
  lib,
  ...
}: let
  nat-common = forward: let
    common =
      forward
      // {
        loopbackIPs = ["198.251.88.245"];
      };
  in
    forwardPort: [
      (common // forwardPort // {proto = "tcp";})
      (common // forwardPort // {proto = "udp";})
    ];
in {
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

  networking.nat.forwardPorts =
    builtins.concatMap (nat-common {
      destination = "10.147.18.10:25565";
      sourcePort = 25565;
    }) [
      {
        destination = "10.147.18.10:25565";
        sourcePort = 25565;
      }
      {
        destination = "10.147.18.10:25566";
        sourcePort = 25566;
      }
      {
        destination = "10.147.18.10:2022";
        sourcePort = 2022;
      }
    ];
}
