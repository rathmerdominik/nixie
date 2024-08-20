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

  virtualisation.podman = {
    dockerSocket.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {dns_enabled = true;};
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
    fqdn-mail-domain = "mail.rathmer.me";
    domain = "hammerclock.net";
    mail-domain = "rathmer.me";
    firewall.allowedTCPPorts = [80 443];
  };
}
