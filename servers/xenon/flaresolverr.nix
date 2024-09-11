{
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:latest";
    ports = ["8191:8191"];
    environment = {
      "TZ" = "Europe/Berlin";
      "HOST" = "0.0.0.0";
      "PORT" = "8191";
    };
    extraOptions = [
      "--pull=always"
    ];
  };
}
