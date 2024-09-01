{
  description = "My NixOS server configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    hardware.url = "github:NixOS/nixos-hardware";
    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
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
            inputs.mailserver.nixosModule
            inputs.authentik-nix.nixosModules.default

            ./common
            ./servers/${name}

            ({lib, ...}: {networking.hostName = lib.mkDefault name;})
          ];

          specialArgs = {
            inherit inputs;
            inherit mylib;
            inherit proxy-ports;
          };
        };
    in {
      xenon = mkSystem "xenon";
      neon = mkSystem "neon";
      krypton = mkSystem "krypton";
      argon = mkSystem "argon";
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
