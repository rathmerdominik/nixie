{proxy-ports, ...}: let
  filebrowser-path = "/srv/disks/mass-storage/filebrowser";
in {
  systemd.tmpfiles.settings."10-filebrowser" = {
    "/srv/disks/mass-storage/filebrowser".d = {
      group = "filebrowser";
      mode = "0755";
      user = "filebrowser";
    };
  };

  services.filebrowser = {
    enable = true;
    stateDir = "${filebrowser-path}";
    settings = {
      port = proxy-ports.filebrowser.port;
    };
  };
}
