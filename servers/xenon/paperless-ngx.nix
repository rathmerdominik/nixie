{
  #   config,
  #   lib,
  #   pkgs,
  #   ...
  # }: {
  #   age.secrets.paperless-ngx.file = ../../secrets/paperless-ngx.age;

  #   services.paperless = {
  #     enable = true;
  #     passwordFile = config.age.secrets.paperless-ngx.path;
  #     openMPThreadingWorkaround = true;
  #     settings = {
  #       PAPERLESS_CORS_ALLOWED_HOSTS = "https://paperless.${config.networking.domain}";
  #       PAPERLESS_OCR_LANGUAGE = "deu+eng";
  #       PAPERLESS_DBHOST = "/run/postgresql";
  #       PAPERLESS_CONSUMER_IGNORE_PATTERN = [".DS_STORE/*" "desktop.ini"];
  #       PAPERLESS_OCR_USER_ARGS = {
  #         optimize = 1;
  #         pdfa_image_compression = "lossless";
  #       };
  #     };
  #   };

  #   services.postgresql = {
  #     ensureDatabases = ["paperless"];
  #   };
}
