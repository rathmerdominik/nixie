{lib, ...}: {
  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkDefault true;
        consoleMode = "max";
      };

      efi = {
        canTouchEfiVariables = lib.mkDefault true;
        efiSysMountPoint = "/boot";
      };
    };
  };
}
