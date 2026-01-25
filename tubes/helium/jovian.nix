{pkgs, ...}: {
  jovian = {
    steam = {
      enable = true;
      user = "dominik";
      autoStart = true;
      desktopSession = "plasma";
      updater.splash = "jovian";
    };
    steamos = {
      enableBluetoothConfig = true;
    };
  };

  programs.steam.fontPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
}
