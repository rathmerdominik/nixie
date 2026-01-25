{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.ryubing
    pkgs.dolphin-emu
  ];
}
