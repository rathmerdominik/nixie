{
  modulesPath,
  lib,
  ...
}: let
  ignoredFiles = lib.fileset.unions [./default.nix];
in {
  imports =
    lib.fileset.toList (lib.fileset.difference ./. ignoredFiles)
    ++ [
      "${modulesPath}/profiles/qemu-guest.nix"
    ];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11";

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
        address = "2a01:4f8:c014:e570::2";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {
      address = "fe80::1";
      inherit interface;
    };
    domain = "hammerclock.net";
  };
}
