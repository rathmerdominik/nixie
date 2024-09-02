{config, ...}: let
  inherit (config.networking) domain;
in {
  age.secrets.mail-hammerclock.file = ../../secrets/mail-hammerclock.age;

  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.mail-hammerclock.path;
    settings = {
      email = {
        host = "mail.${domain}";
        port = 465;
        username = "auth@${domain}";
        use_tls = true;
        use_ssl = true;
        from = "auth@${domain}";
      };
      disable_startup_analytics = true;
      avatars = "gravatar,initials";
    };
  };
}
