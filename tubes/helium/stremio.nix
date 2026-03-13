{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.stremio-linux-shell # Let's use normal stremio for now
  ];
}
