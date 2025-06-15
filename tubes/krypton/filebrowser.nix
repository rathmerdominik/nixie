{
  proxy-ports,
  unstable,
  ...
}: {
  services.filebrowser = {
    enable = true;
    package = unstable.legacyPackages.x86_64-linux.filebrowser;
    settings = {
      port = proxy-ports.files.port;
    };
  };
}
