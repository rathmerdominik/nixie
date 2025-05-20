{proxy-ports, ...}: let
  filebrowser-path = "/srv/disks/mass-storage/filebrowser";
in {
  services.filebrowser = {
    enable = true;
    stateDir = "${filebrowser-path}";
    settings = {
      port = proxy-ports.filebrowser.port;
    };
  };
}
