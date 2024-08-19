{config, ...}: {
  age.secrets.cloudflare-token.file = ../../secrets/cloudflare-token.age;
  services.ddclient = {
    enable = true;
    usev6 = "webv6, webv6=https://ipv6.nsupdate.info/myip";
    usev4 = "";
    protocol = "cloudflare";
    zone = "hammerclock.net";
    username = "token";
    passwordFile = config.age.secrets.cloudflare-token.path;
    domains = [];
  };
}
