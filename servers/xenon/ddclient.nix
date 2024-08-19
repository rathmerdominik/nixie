{config, ...}: {
  age.secrets.cloudflare-token.file = ../../secrets/cloudflare-token.age;
  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    zone = "hammerclock.net";
    username = "token";
    passwordFile = config.age.secrets.cloudflare-token.path;
    domains = ["@"];
  };
}
