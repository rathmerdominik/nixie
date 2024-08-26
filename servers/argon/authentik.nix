{config, ...}: let
  inherit (config.networking) domain;
in {
  age.secrets.mail-hammerclock.file = ../../secrets/mail-hammerclock.age;

  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.mail-hammerclock.path;
  };
}
