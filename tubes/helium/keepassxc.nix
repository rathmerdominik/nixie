{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.keepassxc
  ];
}
