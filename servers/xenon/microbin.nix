{config, ...}: {
  age.secrets.microbin.file = ../../secrets/microbin.age;

  services.microbin = {
    enable = true;
    passwordFile = config.age.secrets.microbin.path;
    settings = ''
      MICROBIN_PUBLIC_PATH="https://microbin.${config.networking.domain}"
      MICROBIN_QR=true
      MICROBIN_ETERNAL_PASTA=true
      MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB=20480
    '';
  };
}
