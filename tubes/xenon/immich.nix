{
  config,
  proxy-ports,
  ...
}: {
  age.secrets.immich.file = ../../secrets/immich.age;
  /*
  services.immich = {
    enable = false;
    openFirewall = true;
    settings = {
      server.externalDomain = "https://photos.${config.networking.domain}";
      newVersionCheck = {enabled = true;}; # what the fuck
    };
    port = proxy-ports.immich.port;
    secretsFile = config.age.secrets.immich.path;
  };
  */
}
