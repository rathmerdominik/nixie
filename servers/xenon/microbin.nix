{config, ...}: {
  services.microbin = {
    enable = true;
    passwordFile = config.age.secrets.microbin.path;
    settings = ''
      MICROBIN_PUBLIC_PATH="https://microbin.${config.networking.domain}"
      MICROBIN_QR=true
      MICROBIN_ETERNAL_PASTA=true
    '';
  };
}
