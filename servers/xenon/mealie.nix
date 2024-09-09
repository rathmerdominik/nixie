{config, ...}: {
  age.secrets.mealie.file = ../../secrets/mealie.age;

  services.mealie = {
    enable = true;
    openFirewall = true;
    credentialsFile = config.age.secrets.mealie.path;
  };
}
