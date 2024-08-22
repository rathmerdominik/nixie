{
  description = "My NixOS server configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/f8e45876ff87bc8de25cbf54ae82bcb8e2ff2910";
    agenix.url = "github:ryantm/agenix";
    hardware.url = "github:NixOS/nixos-hardware";
    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    authentik-nix.url = "github:nix-community/authentik-nix";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux"];

    forAllSupportedSystems = function:
      nixpkgs.lib.genAttrs supportedSystems (system:
        function (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }));
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
