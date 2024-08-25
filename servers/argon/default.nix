{modulesPath, ...}: {
  imports =
    (map (n: ./${n}) (builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./.))))
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
}
