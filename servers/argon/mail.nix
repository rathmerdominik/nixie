{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain;

  wellKnownMtaSts = pkgs.writeText "" ''
    version: STSv1
    mode: enforce
    mx: mail.${domain}
    max_age: 86400
  '';
in {
  age.secrets.mail-hammerclock.file = ../../secrets/mail-hammerclock.age;

  mailserver = {
    enable = true;
    openFirewall = true;
    fqdn = "mail.${domain}";
    domains = [domain];

    loginAccounts = {
      "der@${domain}" = {
        hashedPasswordFile = config.age.secrets.mail-hammerclock.path;
        aliases = ["security@${domain}" "postmaster@${domain}"];
      };
      "panel@${domain}" = {
        hashedPasswordFile = config.age.secrets.mail-hammerclock.path;
      };
      "vault@${domain}" = {
        hashedPasswordFile = config.age.secrets.mail-hammerclock.path;
      };
      "auth@${domain}" = {
        hashedPasswordFile = config.age.secrets.mail-hammerclock.path;
      };
      "photos@${domain}" = {
        hashedPasswordFile = config.age.secrets.mail-hammerclock.path;
      };
      "meals@${domain}" = {
        hashedPasswordFile = config.age.secrets.mail-hammerclock.path;
      };
      "papers@${domain}" = {
        hashedPasswordFile = config.age.secrets.mail-hammerclock.path;
      };
    };

    certificateScheme = "acme-nginx";
  };

  # FIXME: This is unnecessary when https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues/275 is closed <- They still didn't fix this
  services.dovecot2.sieve.extensions = ["fileinto"];

  services.nginx.virtualHosts."mta-sts.${domain}" = {
    enableACME = true;
    forceSSL = true;
    quic = true;

    locations = {
      "/".return = "404";

      "=/.well-known/mta-sts.txt" = {
        alias = wellKnownMtaSts;

        extraConfig = ''
          default_type text/plain;
        '';
      };
    };
  };
}
