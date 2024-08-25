{config, ...}: let
  inherit (config.networking) domain;
in {
  age.secrets.mail-hammerclock.file = ../../secrets/mail-hammerclock.age;

  services.authentik = {
    enable = true;
    environmentFile = "${config.age.secrets.mail-hammerclock.file.path}";
    settings = {
      email = {
        host = "mail.${domain}";
        port = 465;
        username = "authentik@${domain}";
        use_tls = true;
        use_ssl = true;
        from = "authentik@${domain}";
      };
      disable_startup_analytics = true;
      avatars = "initials,gravatar";
    };
    nginx = {
      enable = true;
      enableACME = true;
      host = "auth.${domain}";
    };
  };
}
