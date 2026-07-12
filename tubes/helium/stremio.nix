{pkgs, ...}: {
  # services.flatpak.packages = [
  #   {
  #     appId = "com.stremio.Stremio";
  #     origin = "flathub";
  #   }
  # ];
  environment.systemPackages = [
    pkgs.stremio-linux-shell
  ];
}
