{
  description = "Nixie's server configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    agenix.url = "github:ryantm/agenix";
    hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs = {
    nixpkgs,
    unstable,
    ...
  } @ inputs: let
    domain = "hammerclock.net";
    mylib = import ./lib/mylib.nix {inherit (nixpkgs) lib;};
    proxy-ports = import ./proxy-ports.nix {inherit mylib;};

    mkSystem = name: useUnstable: arch: let
      pkgsSource =
        if useUnstable
        then inputs.unstable
        else inputs.nixpkgs;
    in
      pkgsSource.lib.nixosSystem {
        system = arch;
        specialArgs = {
          inherit inputs;
          inherit mylib;
          inherit proxy-ports;
          inherit unstable;
          inherit domain;
          attrName = name;
        };
        modules = [
          inputs.agenix.nixosModules.default
          inputs.jovian.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
          ./common
          ./tubes/${name}
          ({lib, ...}: {networking.hostName = lib.mkDefault name;})
        ];
      };

    nixosConfigurations = {
      krypton = mkSystem "krypton" false "x86_64-linux";
      helium = mkSystem "helium" true "x86_64-linux";
      neon = mkSystem "neon" false "aarch64-linux";
    };
  in {
    inherit nixosConfigurations;
    inherit inputs;

    packages = {
      aarch64-linux.sdImage = nixosConfigurations.neon.config.system.build.sdImage;
    };
  };
}
