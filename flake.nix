{
  description = "Nixie's server configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    agenix.url = "github:ryantm/agenix";
    hardware.url = "github:NixOS/nixos-hardware";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    unstable,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux"];

    forAllSupportedSystems = function:
      nixpkgs.lib.genAttrs supportedSystems (system:
        function (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.nvidia.acceptLicense = true;
        }));

    mylib = import ./lib/mylib.nix {inherit (nixpkgs) lib;};
    proxy-ports = import ./proxy-ports.nix {inherit mylib;};
  in {
    nixosConfigurations = let
      mkSystem = name:
        nixpkgs.lib.nixosSystem {
          modules = [
            inputs.agenix.nixosModules.default

            ./common
            ./tubes/${name}

            ({lib, ...}: {networking.hostName = lib.mkDefault name;})
          ];

          specialArgs = {
            inherit inputs;
            inherit mylib;
            inherit proxy-ports;
            inherit unstable;
            attrName = name;
            storageBoxUser = "u322470";
          };
        };
    in {
      xenon = mkSystem "xenon";
      krypton = mkSystem "krypton";
    };

    packages = forAllSupportedSystems (pkgs: {
      disk = pkgs.writeShellApplication {
        name = "disk";

        runtimeInputs = with pkgs; [
          util-linux
          jq
          e2fsprogs
          dosfstools
        ];

        text = builtins.readFile ./disk.sh;
      };
    });
  };
}
