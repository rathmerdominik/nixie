{
  config,
  proxy-ports,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.networking) domain;
  certPath = "/var/lib/acme/auth.${domain}/cert.pem";
  certKeyPath = "/var/lib/acme/auth.${domain}/key.pem";
in {
  age.secrets.keycloak-database.file = ../../secrets/keycloak-database.age;

  services.keycloak = {
    plugins = [pkgs.keycloak.plugins.keycloak-discord];
    enable = true;
    sslCertificate = certPath;
    sslCertificateKey = certKeyPath;
    settings = {
      http-host = "127.0.0.1";
      http-port = proxy-ports.keycloak-http.port;
      hostname = "auth.${domain}";
    };
    database = {
      passwordFile = config.age.secrets.keycloak-database.path;
    };
  };

  services.nginx.virtualHosts."auth.${domain}" = {
    enableACME = true;
    forceSSL = true;
    quic = true;

    locations."/" = {
      proxyPass = mylib.formatMappingHttp proxy-ports.keycloak-http;
    };
  };
}
