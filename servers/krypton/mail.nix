{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain mail-domain fqdn;

  wellKnownMtaSts = pkgs.writeText "" ''
    version: STSv1
    mode: enforce
    mx: ${fqdn}
    max_age: 86400
  '';
in {
  age.secrets.mail-dominik.file = ../../secrets/mail-dominik.age;

  mailserver = {
    enable = true;
    openFirewall = true;
    inherit fqdn;
    domains = [mail-domain domain];

    loginAccounts = {
      "dominik@${mail-domain}" = {
        hashedPasswordFile = config.age.secrets.mail-dominik.path;
        aliases = ["postmaster@${mail-domain}"];
      };
      "der@${domain}" = {
        hashedPasswordFile = config.age.secrets.mail-domain.path;
        aliases = ["postmaster@${domain}" "panel@${domain}" "vault@${domain}"];
      };
    };

    certificateScheme = "acme-nginx";
  };

  # FIXME: This is unnecessary when https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues/275 is closed <- They still didnt fix this
  services.dovecot2.sieve.extensions = ["fileinto"];

  services.nginx.virtualHosts."mta-sts.${mail-domain}" = {
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
