{config, ...}: {
  system.autoUpgrade = {
    enable = true;
    dates = "19:00";
    allowReboot = true;
    flake = "github:rathmerdominik/nixie#${config.networking.hostName}";
  };
}
