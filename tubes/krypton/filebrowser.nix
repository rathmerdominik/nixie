{proxy-ports, ...}: let
  filebrowserPath = "/srv/big-storage/filebrowser";
in {
  services.filebrowser = {
    enable = true;
    settings = {
      root = "${filebrowserPath}/data";
      address = "0.0.0.0";
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
