{
  services.zerotierone = {
    enable = true;
    joinNetworks = ["a84ac5c10acf5761"];
  };

  networking.hosts = {
    "10.147.18.13" = ["argon"];
    "10.147.18.12" = ["neon"];
    "10.147.18.11" = ["krypton"];
    "10.147.18.10" = ["xenon"];
  };
}
