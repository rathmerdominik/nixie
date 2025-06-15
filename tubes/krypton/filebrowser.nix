{proxy-ports, ...}: let
  filebrowserPath = "/srv";
in {
  services.filebrowser = {
    enable = true;
    stateDir = filebrowserPath;
    settings = {
      port = proxy-ports.files.port;
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
