{modulesPath, ...}: {
  imports =
    (map (n: ./${n}) (builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./.))))
    ++ [
      "${modulesPath}/profiles/qemu-guest.nix"
    ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "virtio_blk"];

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
}
