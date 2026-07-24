{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.stremio-linux-shell
  ];
}
