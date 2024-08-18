{config, ...}: {
  age.secrets.vaultwarden-env.file = ../../secrets/vaultwarden-env.age;

  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets.vaultwarden-env.path;
    config = {
      DATA_FOLDER = "/var/lib/vaultwarden";
      DOMAIN = "http://bitwarden.hammerclock.net";
      SIGNUPS_ALLOWED = false;
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "0.0.0.0";
      WEBSOCKET_PORT = 3012;
    };
  };

  services.nginx.virtualHosts = let
    inherit (config.networking) domain;
  in {
    "bitwarden.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."/" = {
        proxyPass = "http://localhost:8000";
        proxyWebsockets = true;
      };
    };
  };

  systemd.tmpfiles.settings."20-vaultwarden" = {
    "/var/lib/vaultwarden".d = {
      group = "vaultwarden";
      mode = "0755";
      user = "vaultwarden";
    };
  };
}
