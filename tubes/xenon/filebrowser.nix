{
  proxy-ports,
  unstable,
  ...
}: let
  filebrowserPath = "/srv/disks/mass-storage/filebrowser";
in {
  services.filebrowser = {
    enable = true;
    package = unstable.legacyPackages.x86_64-linux.filebrowser;
    stateDir = filebrowserPath;
    settings = {
      port = proxy-ports.cloud.port;
    };
  };

  systemd.tmpfiles.settings."10-filebrowser" = {
    filebrowserPath.d = {
      group = "filebrowser";
      mode = "0755";
      user = "filebrowser";
    };
  };
}
