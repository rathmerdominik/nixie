{
  description = "Nixie's server configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    agenix.url = "github:ryantm/agenix";
    hardware.url = "github:NixOS/nixos-hardware";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs = {
    nixpkgs,
    unstable,
    ...
  } @ inputs: let
    mylib = import ./lib/mylib.nix {inherit (nixpkgs) lib;};
    proxy-ports = import ./proxy-ports.nix {inherit mylib;};
    storageBoxUser = "u322470";
    primary-domain = "hammerclock.net";
    secondary-domain = "rathmer.me";
  in {
    nixosConfigurations = let
      mkSystem = name: useUnstable: let
        pkgsSource =
          if useUnstable
          then inputs.unstable
          else inputs.nixpkgs;
      in
        pkgsSource.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit primary-domain;
            inherit secondary-domain;
            inherit mylib;
            inherit proxy-ports;
            inherit storageBoxUser;
            inherit unstable;
            attrName = name;
          };
          modules =
            [
              inputs.agenix.nixosModules.default
              ./common
              ./tubes/${name}
              ({lib, ...}: {networking.hostName = lib.mkDefault name;})
            ]
            ++ (
              if name == "helium"
              then [
                inputs.jovian.nixosModules.default
                inputs.nix-flatpak.nixosModules.nix-flatpak
              ]
              else []
            );
        };
    in {
      krypton = mkSystem "krypton" false;
      helium = mkSystem "helium" true;
    };
  };
}
