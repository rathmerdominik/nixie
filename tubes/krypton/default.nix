{
  modulesPath,
  lib,
  proxy-ports,
  ...
}: let
  nat-common = forward: let
    common =
      forward
      // {
        loopbackIPs = ["157.90.126.175"];
      };
  in
    forwardPort: [
      (common // forwardPort // {proto = "tcp";})
      (common // forwardPort // {proto = "udp";})
    ];
  xenon-internal = "10.147.18.10";
  ignoredFiles = lib.fileset.unions [./default.nix];
in {
  imports =
    lib.fileset.toList (lib.fileset.difference ./. ignoredFiles)
    ++ [
      "${modulesPath}/profiles/qemu-guest.nix"
    ];

  boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod"];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.11";

  powerManagement.cpuFreqGovernor = "performance";

  virtualisation.oci-containers.backend = "docker";

  virtualisation.docker.daemon.settings = {
    ipv6 = true;
    fixed-cidr-v6 = "2001:db8:1::/64";
  };

  security.acme = {
    defaults.email = "postmaster@hammerclock.net";
    acceptTerms = true;
  };

  networking = let
    interface = "enp1s0";
  in {
    interfaces.${interface}.ipv6.addresses = [
      {
        address = "2a01:4f8:1c1c:26c9::2";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {
      address = "fe80::1";
      inherit interface;
    };
    domain = "hammerclock.net";
    nat = {
      enable = true;
      internalInterfaces = ["enp1s0" "ztnfaavftl"];
      externalInterface = "ztnfaavftl";
      forwardPorts =
        builtins.concatMap (nat-common {
          destination = "${xenon-internal}:${proxy-ports.wings-sftp}";
          sourcePort = proxy-ports.wings-sftp;
        }) [
          # More entries if needed
        ];
    };
  };
}
