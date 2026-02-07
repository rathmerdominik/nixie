{
  config,
  lib,
  pkgs,
  ...
}: {
  age.secrets.forgejo.file = ../../secrets/forgejo.age;
  age.secrets.forgejo-admin.file = ../../secrets/forgejo-admin.age;

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    database.type = "postgres";
    lfs.enable = true;
    dump = {
      enable = true;
      interval = "*-*-* 02:00:00";
      backupDir = "/var/backup/forgejo";
    };
    settings = {
      server = {
        DOMAIN = "git.hammerclock.net";
        ROOT_URL = "https://git.${config.networking.domain}/";
        HTTP_ADDR = "krypton";
        HTTP_PORT = 8020;
      };

      service = {
        DISABLE_REGISTRATION = true;
        ENABLE_NOTIFY_MAIL = true;
      };

      mailer = {
        ENABLED = true;
        SMTP_ADDR = "smtp.fastmail.com";
        FROM = "git@hammerclock.net";
        USER = "dominik@rathmer.me";
      };

      log.LEVEL = "Debug";
    };

    secrets = {
      mailer = {
        PASSWD = config.age.secrets.forgejo.path;
      };
    };
  };

  systemd.services.forgejo.preStart = lib.getExe (
    pkgs.writeShellApplication {
      name = "forgejo-init-admin";
      text = let
        forgejoExe = lib.getExe pkgs.forgejo;
        passwordFile = config.age.secrets.forgejo-admin.path;
      in ''
        admins=$(${forgejoExe} admin user list --admin | wc --lines)
        admins=$((admins - 1))

        if ((admins < 1)); then
          ${forgejoExe} admin user create \
            --admin \
            --email dominik@rathmer.me \
            --username hammerclock \
            --password "$(cat -- ${passwordFile})"
        fi
      '';
    }
  );
}
