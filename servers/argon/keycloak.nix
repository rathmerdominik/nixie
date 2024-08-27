{
  lib,
  config,
  ...
}: let
  inherit (config.networking) domain;
  ports = import ../../proxyports.nix;
  certPath = /var/lib/acme/auth.${domain}/cert.pem;
  certKeyPath = /var/lib/acme/auth.${domain}/key.pem;
in {
  age.secrets.mail-hammerclock.file = ../../secrets/mail-hammerclock.age;

  services.keycloak = {
    enable = true;
    sslCertificate = certPath;
    sslCertificateKey = certKeyPath;
    settings = {
      http-host = "127.0.0.1";
      https-port = builtins.elemAt (lib.strings.splitString ":" "${ports.keycloak}") 1;
    };
  };

  services.nginx.virtualHosts."auth.${domain}" = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = "${ports.keycloak}";
    };
  };
}
