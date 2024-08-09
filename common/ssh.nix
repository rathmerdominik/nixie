{
  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  services.openssh = {
    enable = true;
    openFirewall = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    extraConfig = ''
      Compression yes
      ServerAliveInterval 60
    '';
  };
}
