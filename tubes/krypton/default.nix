{
  modulesPath,
  lib,
  config,
  domain,
  ...
}: let
  ignoredFiles = lib.fileset.unions [./default.nix];
  acmeEmail = "postmaster@${config.networking.domain}";
  secretsPath = ../../secrets;
  secretsPathNetwork = "${secretsPath}/network";
  secretsPathHetzner = "${secretsPath}/hetzner";
in {
  age.secrets.network-domain.file = "${secretsPathNetwork}/domain.age";
  age.secrets."storage-user".file = "${secretsPathHetzner}/storage-user.age";

  imports =
    lib.fileset.toList (lib.fileset.difference ./. ignoredFiles)
    ++ [
      "${modulesPath}/profiles/qemu-guest.nix"
    ];
  powerManagement.cpuFreqGovernor = "performance";

  virtualisation = {
    oci-containers.backend = "docker";
    docker.daemon.settings = {
      ipv6 = true;
      fixed-cidr-v6 = "2001:db8:1::/64";
    };
  };

  security.acme = {
    defaults.email = acmeEmail;
    acceptTerms = true;
  };

  boot = {
    initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
    supportedFilesystems = ["fuse"];
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
    domain = domain;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11";
}
