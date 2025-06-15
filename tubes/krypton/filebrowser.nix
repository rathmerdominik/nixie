{proxy-ports, ...}: {
  services.filebrowser = {
    enable = true;
    settings = {
      address = "0.0.0.0";
      port = proxy-ports.files.port;
    };
  };
}
