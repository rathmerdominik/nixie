{config, ...}: {
  age.secrets.homarr.file = ../../secrets/homarr.age;

  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/ajnart/homarr:latest";
    ports = [
      "7575:7575"
    ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/var/lib/homarr/configs:/app/data/configs"
      "/var/lib/homarr/icons:/app/public/icons"
      "/var/lib/homarr/data:/data"
    ];
    extraOptions = ["--pull=always"];
    environmentFiles = [
      config.age.secrets.homarr.path
    ];
  };
}
