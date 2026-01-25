{
  services.zerotierone = {
    enable = true;
    joinNetworks = ["a84ac5c10acf5761"];
  };

  networking.hosts = {
    "10.147.18.10" = ["helium"];
    "10.147.18.11" = ["krypton"];
  };
}
