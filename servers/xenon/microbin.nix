{config, ...}: {
  age.secrets.microbin.file = ../../secrets/microbin.age;

  services.microbin = {
    enable = true;
    passwordFile = config.age.secrets.microbin.path;
    settings = {
      MICROBIN_PUBLIC_PATH = "https://paste.${config.networking.domain}";
      MICROBIN_QR = true;
      MICROBIN_ETERNAL_PASTA = true;

      MICROBIN_ENCRYPTION_CLIENT_SIDE = true;
      MICROBIN_MAX_FILE_SIZE_ENCRYPTED_MB = 1024;
      MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB = 20480;

      MICROBIN_BIND = "0.0.0.0";
      MICROBIN_PORT = 9020;

      MICROBIN_ENABLE_READONLY = true;

      MICROBIN_DISABLE_UPDATE_CHECKING = false;
      MICROBIN_DISABLE_TELEMETRY = true;
      MICROBIN_LIST_SERVER = false;
    };
  };
}
