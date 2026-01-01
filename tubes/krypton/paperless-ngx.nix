{
  config,
  pkgs,
  ...
}: let
  paperless-root = "/srv/big-storage/paperless";
  paperless-domain = "papers.${config.networking.domain}";
  consumption-dir = "${paperless-root}/consumption";
  media-dir = "${paperless-root}/media";
  trash-dir = "${config.services.paperless.dataDir}/trash";
in {
  age.secrets.paperless-ngx.file = ../../secrets/paperless-ngx.age;
  age.secrets.paperless-ngx-mail = {
    file = ../../secrets/paperless-ngx-mail.age;
    owner = "paperless";
    group = "paperless";
  };

  environment.systemPackages = [
    pkgs.zxing
  ];

  services.paperless = {
    enable = false;
    address = "0.0.0.0";
    passwordFile = config.age.secrets.paperless-ngx.path;
    openMPThreadingWorkaround = true;
    consumptionDir = consumption-dir;
    consumptionDirIsPublic = true;
    mediaDir = media-dir;
    settings = {
      PAPERLESS_URL = "https://${paperless-domain}";
      PAPERLESS_ALLOWED_HOSTS = paperless-domain;
      PAPERLESS_CORS_ALLOWED_HOSTS = "https://${paperless-domain}";

      PAPERLESS_DBHOST = "/run/postgresql";

      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
        continue_on_soft_render_error = true;
      };

      PAPERLESS_TIKA_ENABLED = true;
      PAPERLESS_TIKA_ENDPOINT = "http://localhost:9998";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://localhost:3000";

      PAPERLESS_CONSUMER_ENABLE_BARCODES = true;
      PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
      PAPERLESS_CONSUMER_BARCODE_SCANNER = "ZXING";
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [".DS_STORE/*" "desktop.ini"];

      PAPERLESS_ENABLE_COMPRESSION = false;

      PAPERLESS_TASK_WORKERS = 4;
      PAPERLESS_WEBSERVER_WORKERS = 4;
      PAPERLESS_NUMBER_OF_SUGGESTED_DATES = 8;

      PAPERLESS_EMPTY_TRASH_DIR = "${trash-dir}";

      PAPERLESS_FILENAME_FORMAT = "{owner_username}/{created_year}-{created_month}-{created_day}_{asn}_{title}";

      PAPERLESS_ACCOUNT_SESSION_REMEMBER = true;
    };
  };

  systemd.services.paperless-web = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.paperless-ngx-mail.path;
    };
  };

  services.tika = {
    enable = true;
    enableOcr = true;
    listenAddress = "0.0.0.0";
  };

  services.gotenberg = {
    enable = true;
  };

  systemd.tmpfiles.settings."10-paperless-trash" = {
    "${trash-dir}".d = {
      group = "paperless";
      mode = "0755";
      user = "paperless";
    };
  };

  users = {
    groups.paperless = {};
    users.paperless = {
      group = "paperless";
      isSystemUser = true;
    };
  };
}
