{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.stremio
  ];
}
