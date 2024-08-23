{modulesPath, ...}: {
  imports =
    (map (n: ./${n}) (builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./.))))
    ++ [
      "${modulesPath}/profiles/qemu-guest.nix"
    ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sr_mod" "virtio_blk"];
  boot.kernelModules = - ["kvm-amd"];

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "24.11";

  powerManagement.cpuFreqGovernor = "performance";

  networking = {
    domain = "hammerclock.net";
  };

  security.acme = {
    defaults.email = "dominik@rathmer.me";
    acceptTerms = true;
  };

  # BuyVM's shitty service take 7 euro for a suboptimal 2 GB RAM and intel based single core 3.5 Ghz VPS.
  # But with additional 3 Euro you get a very good Anti-DDOS solution...
  swapDevices = [
    {
      device = "/swapfile";
      size = 6 * 1024;
    }
  ];
}
