{
  config,
  lib,
  pkgs,
  mylib,
  proxy-ports,
  ...
}: let
  domain = "git.${config.networking.domain}";
  backupPath = "/var/backup/forgejo";
  secretsPath = ../../secrets/forgejo;
  mailerMail = "git@${config.networking.domain}";
in {
  age.secrets.forgejo-env.file = "${secretsPath}/env.age";
  age.secrets.forgejo-admin.file = "${secretsPath}/admin.age";
  age.secrets.forgejo-mail.file = "${secretsPath}/mail.age";
  age.secrets.forgejo-user.file = "${secretsPath}/user.age";

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    database.type = "postgres";
    lfs.enable = true;
    dump = {
      enable = true;
      interval = "*-*-* 02:00:00";
      backupDir = backupPath;
    };
    settings = {
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}/";
        HTTP_ADDR = "krypton";
        HTTP_PORT = proxy-ports.git.port;
        SSH_PORT = builtins.head config.services.openssh.ports;
      };

      service = {
        DISABLE_REGISTRATION = true;
        ENABLE_NOTIFY_MAIL = true;
      };

      mailer = {
        ENABLED = true;
        SMTP_ADDR = "smtp.fastmail.com";
        FROM = mailerMail;
        USER = config.age.secrets.users-dominik-mail.path;
      };

      log.LEVEL = "Debug";
    };

    secrets = {
      mailer = {
        PASSWD = config.age.secrets.forgejo-env.path;
      };
    };
  };

  systemd.services.forgejo.preStart = lib.getExe (
    pkgs.writeShellApplication {
      name = "forgejo-init-admin";
      text = let
        forgejoExe = lib.getExe pkgs.forgejo;
        passwordFile = config.age.secrets.forgejo-admin.path;
        mailFile = config.age.secrets.forgejo-mail.path;
        usernameFile = config.age.secrets.forgejo-user.path;
      in ''
        admins=$(${forgejoExe} admin user list --admin | wc --lines)
        admins=$((admins - 1))

        if ((admins < 1)); then
          mail="$(cat -- ${mailFile})"
          username="$(cat -- ${usernameFile})"

          ${forgejoExe} admin user create \
            --admin \
            --email "$mail" \
            --username "$username" \
            --password "$(cat -- ${passwordFile})"
        fi
      '';
    }
  );

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    quic = true;

    locations."/" = {
      proxyPass = mylib.formatMappingHttp proxy-ports.git;
      extraConfig = ''
        client_max_body_size 512m;
      '';
    };
  };
}
