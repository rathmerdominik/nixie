{config, ...}: {
  age.secrets.cloudflare-token.file = ../../secrets/cloudflare-token.age;
  services.ddclient = {
    enable = true;
    usev6 = "use=cmd, cmd='curl -k -s http://checkip6.spdyn.de'";
    protocol = "cloudflare";
    zone = "hammerclock.net";
    username = "token";
    passwordFile = config.age.secrets.cloudflare-token.path;
    domains = ["@"];
    extraConfig = "ipv4=no";
  };
}
