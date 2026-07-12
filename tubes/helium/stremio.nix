{...}: {
  services.flatpak.packages = [
    {
      appId = "com.stremio.Stremio";
      origin = "flathub";
    }
  ];
}
