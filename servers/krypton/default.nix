{modulesPath, ...}: {
  imports =
    (map (n: ./${n}) (builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./.))))
    ++ [
      "${modulesPath}/profiles/qemu-guest.nix"
    ];

  boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod"];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.11";

  powerManagement.cpuFreqGovernor = "performance";

  virtualisation.oci-containers.backend = "docker";

  networking = {
    fqdn-mail-domain = "mail.rathmer.me";
    domain = "hammerclock.net";
    mail-domain = "rathmer.me";
    firewall.allowedTCPPorts = [80 443];
    nameservers = ["1.1.1.1" "0.0.0.0"];
  };
}
