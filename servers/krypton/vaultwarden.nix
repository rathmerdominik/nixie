{config, ...}: {
  age.secrets.vaultwarden-env.file = ../../secrets/vaultwarden-env.age;

  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets.vaultwarden-env.path;
    config = {
      DATA_FOLDER = "/var/lib/vaultwarden";
      DOMAIN = "https://bitwarden.hammerclock.net";
      SIGNUPS_ALLOWED = false;
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "0.0.0.0";
      WEBSOCKET_PORT = 3012;
    };
  };
}
