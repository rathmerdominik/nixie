{
  lib,
  inputs,
  ...
}: {
  imports =
    [
      ./firefly-iii.nix
      ./fs.nix
      ./grafana.nix
      ./homarr.nix
      ./immich.nix
      ./jellyfin.nix
      ./jellyseerr.nix
      ./mealie.nix
      ./microbin.nix
      ./netdata.nix
      ./ntfy.nix
      ./nvidia.nix
      ./postgres.nix
      ./prowlarr.nix
      ./paperless-ngx.nix
      ./radarr.nix
      ./romm.nix
      ./sonarr.nix
      ./sunshine.nix
      ./syncthing.nix
      ./wings.nix
    ]
    ++ [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
      inputs.hardware.nixosModules.common-pc-ssd
    ];
  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "24.11";

  powerManagement.cpuFreqGovernor = "performance";

  virtualisation.oci-containers.backend = "docker";

  networking = {
    firewall.enable = false;
    domain = "hammerclock.net";
  };
}
