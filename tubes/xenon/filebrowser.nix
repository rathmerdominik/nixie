{proxy-ports, ...}: let
  filebrowserPath = "/srv/disks/mass-storage/filebrowser";
in {
  services.filebrowser = {
    enable = true;
    stateDir = filebrowserPath;
    settings = {
      port = proxy-ports.filebrowser.port;
    };
  };

  systemd.tmpfiles.settings."10-filebrowser" = {
    "/srv/disks/mass-storage/filebrowser".d = {
      group = "filebrowser";
      mode = "0755";
      user = "filebrowser";
    };
  };
}
