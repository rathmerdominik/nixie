{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.fladder
  ];
}
