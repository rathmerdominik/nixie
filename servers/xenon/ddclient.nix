{config, ...}: {
  age.secrets.cloudflare-token.file = ../../secrets/cloudflare-token.age;
  services.ddclient = {
    enable = true;
    usev6 = ;
    protocol = "cloudflare";
    zone = "hammerclock.net";
    username = "token";
    passwordFile = config.age.secrets.cloudflare-token.path;
    domains = ["@"];
    extraConfig = "ipv6=yes\nipv4=no";
  };
}
