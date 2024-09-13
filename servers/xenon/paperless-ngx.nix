{
  config,
  lib,
  pkgs,
  ...
}: let
  paperless-root = "/srv/mergerfs/storage/paperless";
  paperless-domain = "papers.${config.networking.domain}";
  consumption-dir = "${paperless-root}/consumption";
  media-dir = "${paperless-root}/media";
  trash-dir = "${config.services.paperless.dataDir}/trash";
in {
  age.secrets.paperless-ngx.file = ../../secrets/paperless-ngx.age;
  age.secrets.paperless-ngx-oidc = {
    file = ../../secrets/paperless-ngx-oidc.age;
    owner = "paperless";
    group = "paperless";
  };
  age.secrets.paperless-ngx-mail = {
    file = ../../secrets/paperless-ngx-mail.age;
    owner = "paperless";
    group = "paperless";
  };

  environment.systemPackages = [
    pkgs.zxing
  ];

  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    passwordFile = config.age.secrets.paperless-ngx.path;
    openMPThreadingWorkaround = true;
    consumptionDir = consumption-dir;
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

      # PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
      # PAPERLESS_SOCIAL_AUTO_SIGNUP = true;
      # PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
      # PAPERLESS_DISABLE_REGULAR_LOGIN = true;
      # PAPERLESS_ACCOUNT_SESSION_REMEMBER = true;
      # PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON {
      #   openid_connect = {
      #     OAUTH_PKCE_ENABLED = "True";
      #     APPS = [
      #       rec {
      #         provider_id = "authentik";
      #         name = "Authentik";
      #         client_id = "ugzaxafTovEbtdRQA5BsBrZomYeFDbPxuuip48nm";
      #         settings.server_url = "https://auth.${config.networking.domain}/application/o/${client_id}/.well-known/openid-configuration";
      #       }
      #     ];
      #   };
      # };
    };
  };

  systemd.services.paperless-web = {
    # script = lib.mkBefore ''
    #   oidcSecret=$(< ${config.age.secrets.paperless-ngx-oidc.path})
    #   export PAPERLESS_SOCIALACCOUNT_PROVIDERS=$(
    #     ${pkgs.jq}/bin/jq <<< "$PAPERLESS_SOCIALACCOUNT_PROVIDERS" \
    #       --compact-output \
    #       --arg oidcSecret "$oidcSecret" '.openid_connect.APPS.[0].secret = $oidcSecret'
    #   )
    # '';
    serviceConfig = {
      EnvironmentFile = config.age.secrets.paperless-ngx-mail.path;
    };
  };

  services.tika = {
    enable = true;
    enableOcr = true;
    listenAddress = "0.0.0.0";
  };

  # # This here core dumps...
  # services.gotenberg = {
  #   enable = true;
  # };

  virtualisation.oci-containers.containers.gotenberg = {
    image = "gotenberg/gotenberg:8";
    ports = ["3000:3000"];
  };

  systemd.tmpfiles.settings."10-paperless-trash" = {
    "${trash-dir}".d = {
      group = "paperless";
      mode = "0755";
      user = "paperless";
    };
  };
}
