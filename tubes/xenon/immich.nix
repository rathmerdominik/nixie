{
  config,
  proxy-ports,
  ...
}: {
  age.secrets.immich.file = ../../secrets/immich.age;

  services.immich = {
    enable = true;
    openFirewall = true;
    settings = {
      server.externalDomain = "https://photos.${config.networking.domain}";
      newVersionCheck = true;
    };
    port = proxy-ports.immich.port;
    secretsFile = config.age.secrets.immich.path;
  };
}
