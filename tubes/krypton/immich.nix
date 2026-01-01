{
  config,
  proxy-ports,
  unstable,
  ...
}: let
  immichMediaPath = "/srv/big-storage/immich";
in {
  age.secrets.immich.file = ../../secrets/immich.age;
  services.immich = {
    enable = true;
    openFirewall = true;
    package = unstable.legacyPackages.x86_64-linux.immich;
    settings = {
      server.externalDomain = "https://photos.${config.networking.domain}";
      newVersionCheck.enabled = true;
    };
    port = proxy-ports.immich.port;
    secretsFile = config.age.secrets.immich.path;
    host = "0.0.0.0";
    mediaLocation = immichMediaPath;
    accelerationDevices = ["/dev/dri/renderD128"];
  };

  systemd.tmpfiles.settings."10-immich" = {
    "${immichMediaPath}".d = {
      group = "immich";
      mode = "0755";
      user = "immich";
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/418799#issuecomment-3000580361
  users.users.immich = {
    home = immichMediaPath;
    createHome = true;
  };
}
