{
  mylib,
  config,
  proxy-ports,
  ...
}: let
  domain = "vault.${config.networking.domain}";
  backupPath = "/var/backup/vaultwarden";
in {
  age.secrets.vaultwarden-env.file = ../../secrets/vaultwarden/env.age;

  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets.vaultwarden-env.path;
    backupDir = backupPath;
    config = {
      DATA_FOLDER = "/var/lib/vaultwarden";
      DOMAIN = "https://${domain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "0.0.0.0";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    quic = true;

    locations."/" = {
      proxyWebsockets = true;
      proxyPass = mylib.formatMappingHttp proxy-ports.vaultwarden;
    };
  };

  networking.firewall.allowedTCPPorts = [8000];
}
