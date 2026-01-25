{
  config,
  inputs,
  lib,
  ...
}: {
  nix = {
    registry = lib.mkDefault (lib.mapAttrs (_: value: {flake = value;}) inputs);

    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      trusted-users = ["@wheel"];
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      download-buffer-size = 104857600; # 100MB
    };
  };

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
}
