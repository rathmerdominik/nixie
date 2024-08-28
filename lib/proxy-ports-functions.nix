{lib, ...}: let
  restructureService = host: serviceName: port: {
    inherit host;
    port = port;
  };

  restructureHost = host: services:
    lib.mapAttrs (serviceName: port: restructureService host serviceName port) services;

  restructure = input: let
    restructured = lib.mapAttrs restructureHost input;
  in
    builtins.foldl' (acc: next: acc // next) {} (lib.attrValues restructured);

  formatMapping = {
    host,
    port,
  }: "${host}:${builtins.toString port}";
in {
  inherit restructure formatMapping;
}
