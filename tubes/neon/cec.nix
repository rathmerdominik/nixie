{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.libcec
    pkgs.v4l-utils
    pkgs.libv4l
  ];
}
