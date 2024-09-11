{
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:latest";
    ports = ["8191:8191"];
    environment = {
      "TZ" = "Europe/Berlin";
      "HOST" = "10.147.18.10";
      "PORT" = "8191";
    };
  };
}
