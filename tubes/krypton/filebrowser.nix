{proxy-ports, ...}: {
  services.filebrowser = {
    enable = true;
    settings = {
      port = proxy-ports.files.port;
    };
  };
}
