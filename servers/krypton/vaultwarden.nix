{config, ...}: {
  age.secrets.vaultwarden-env.file = ../../secrets/vaultwarden-env.age;

  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets.vaultwarden-env.path;
    backupDir = "/var/backup/vaultwarden";
    config = {
      DATA_FOLDER = "/var/lib/vaultwarden";
      DOMAIN = "https://vault.hammerclock.net";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "0.0.0.0";
    };
  };

  networking.firewall.allowedTCPPorts = [8000];
}
