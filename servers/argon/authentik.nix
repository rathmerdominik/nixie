{config, ...}: {
  age.secrets.authentik-env.file = ../../secrets/authentik-env.age;

  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentik-env.path;
    settings = {
      email = {
        host = "hammerclock.net";
        port = 587;
        username = "auth@hammerclock.net";
        use_tls = true;
        use_ssl = false;
        from = "auth@hammerclock.net";
      };
      disable_startup_analytics = true;
      avatars = "initials,gravatar";
    };
    nginx = {
      enable = true;
      enableACME = true;
      host = "auth.hammerclock.net";
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
