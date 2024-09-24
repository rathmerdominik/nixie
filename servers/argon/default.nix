{
  modulesPath,
  lib,
  ...
}: let
  nat-common = forward: let
    common =
      forward
      // {
        loopbackIPs = ["49.12.237.227"];
      };
  in
    forwardPort: [
      (common // forwardPort // {proto = "tcp";})
      (common // forwardPort // {proto = "udp";})
    ];
  xenon-internal = "10.147.18.10";
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

  networking = {
    firewall.enable = false;
    hosts = {
      "10.0.0.20" = ["krypton"];
    };
    nat = {
      enable = true;
      internalInterfaces = ["ens3" "ztnfaavftl"];
      externalInterface = "ztnfaavftl";
      forwardPorts =
        builtins.concatMap (nat-common {
          destination = "${xenon-internal}:25565";
          sourcePort = 25565;
        }) [
          {
            destination = "${xenon-internal}:25565";
            sourcePort = 25565;
          }
          {
            destination = "${xenon-internal}:25566";
            sourcePort = 25566;
          }
          {
            destination = "${xenon-internal}:2022";
            sourcePort = 2022;
          }
        ];
    };
  };
}
