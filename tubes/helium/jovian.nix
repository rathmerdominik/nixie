{pkgs, ...}: {
  jovian = {
    steam = {
      enable = true;
      user = "dominik";
      autoStart = true;
      desktopSession = "gnome";
      updater.splash = "jovian";
    };
  };

  programs.steam.fontPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
}
