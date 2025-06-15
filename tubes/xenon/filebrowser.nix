{proxy-ports, ...}: let
  filebrowserPath = "/srv/disks/mass-storage/filebrowser";
in {
  services.filebrowser = {
    enable = true;
    settings = {
      root = filebrowserPath;
      address = "0.0.0.0";
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
