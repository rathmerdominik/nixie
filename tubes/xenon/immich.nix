{
  config,
  proxy-ports,
  unstable,
  ...
}: let
  immichMediaPath = "/srv/disks/mass-storage/immich";
in {
  age.secrets.immich.file = ../../secrets/immich.age;
  services.immich = {
    enable = true;
    openFirewall = true;
    package = unstable.legacyPackages.x86_64-linux.immich;
    settings = {
      server.externalDomain = "https://photos.${config.networking.domain}";
      newVersionCheck = {enabled = true;}; # what the fuck
    };
    port = proxy-ports.immich.port;
    secretsFile = config.age.secrets.immich.path;
    host = "0.0.0.0";
    mediaLocation = immichMediaPath;
  };

  systemd.tmpfiles.settings."10-immich" = {
    "${immichMediaPath}".d = {
      group = "immich";
      mode = "0755";
      user = "immich";
    };
  };
}
