{
  #   config,
  #   proxy-ports,
  #   mylib,
  #   pkgs,
  #   ...
  # }: let
  #   inherit (config.networking) domain;
  #   certPath = "/var/lib/acme/auth.${domain}/cert.pem";
  #   certKeyPath = "/var/lib/acme/auth.${domain}/key.pem";
  # in {
  #   age.secrets.keycloak-database.file = ../../secrets/keycloak-database.age;

  #   services.keycloak = {
  #     plugins = [pkgs.keycloak.plugins.keycloak-discord];
  #     enable = true;
  #     sslCertificate = certPath;
  #     sslCertificateKey = certKeyPath;
  #     settings = {
  #       proxy = "edge";
  #       http-host = proxy-ports.keycloak-http.host;
  #       http-port = proxy-ports.keycloak-http.port;
  #       https-port = proxy-ports.keycloak-https.port;
  #       hostname = "auth.${domain}";
  #     };
  #     database = {
  #       passwordFile = config.age.secrets.keycloak-database.path;
  #     };
  #     initialAdminPassword = "d00hickey";
  #   };

  #   services.nginx.virtualHosts."auth.${domain}" = {
  #     enableACME = true;
  #     forceSSL = true;
  #     quic = true;

  #     locations."/" = {
  #       proxyPass = mylib.formatMappingHttp proxy-ports.keycloak-http;
  #     };
  #   };
}
