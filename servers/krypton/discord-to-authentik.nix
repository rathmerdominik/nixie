{config, ...}: {
  age.secrets.discord-to-authentik.file = ../../secrets/discord-to-authentik.age;

  services.discord-to-authentik = {
    enable = true;
    environmentFile = config.age.secrets.discord-to-authentik.path;
  };
}
