{
  modulesPath,
  lib,
  config,
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

  boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod"];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.11";

  powerManagement.cpuFreqGovernor = "performance";

  security.acme = {
    defaults.email = "security@hammerclock.net";
    acceptTerms = true;
  };

  networking = let
    interface = "enp1s0";
  in {
    domain = "hammerclock.net";

    interfaces.${interface}.ipv6.addresses = [
      {
        address = "2a01:4f8:1c1e:83e5::2";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {
      address = "fe80::1";
      inherit interface;
    };
    firewall.enable = false;
    nat = {
      enable = true;
      internalInterfaces = ["enp1s0" "ztnfaavftl"];
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
