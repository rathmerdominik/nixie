{
  lib,
  inputs,
  ...
}: {
  imports =
    lib.pipe (builtins.readDir ./.) [(lib.mapAttrsToList (name: type: {inherit name type;})) (builtins.filter (file: file.type != "directory" && file.name != "default.nix")) (map (file: ./${file.name}))]
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
