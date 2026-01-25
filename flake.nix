{
  description = "Nixie's server configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
    hardware.url = "github:NixOS/nixos-hardware";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    zap.url = "git+https://hack.helveticanonstandard.net/helvetica/zap.git";
  };

  outputs = {
    nixpkgs,
    unstable,
    ...
  } @ inputs: let
    mylib = import ./lib/mylib.nix {inherit (nixpkgs) lib;};
    proxy-ports = import ./proxy-ports.nix {inherit mylib;};
    storageBoxUser = "u322470";
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
              then [inputs.jovian.nixosModules.default]
              else []
            );
        };
    in {
      krypton = mkSystem "krypton" false;
      helium = mkSystem "helium" true;
    };

    packages.zap = inputs.zap.packages.default;
  };
}
