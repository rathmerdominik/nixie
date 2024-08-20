{
  config,
  ...
}:
{
  age.secrets.zerotier-api.file = ../../secrets/zerotier-api.age;

  services.zeronsd.servedNetworks."a84ac5c10acf5761".settings = {
    token = config.age.secrets.zerotier-api.path;
    domain = "clock.net";
  };
}