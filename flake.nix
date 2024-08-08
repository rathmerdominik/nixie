{
  description = "My NixOS server configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    agenix.url = "github:ryantm/agenix";
    hardware.url = "github:NixOS/nixos-hardware";
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
    nixosConfigurations = {
      xenon = nixpkgs.lib.nixosSystem {
        modules = [
          inputs.agenix.nixosModules.default

          ./common
          ./servers/xenon

          ({lib, ...}: {networking.hostName = lib.mkDefault "xenon";})
        ];

        specialArgs = {
          inherit inputs;
          # TODO importAll
        };
      };
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
