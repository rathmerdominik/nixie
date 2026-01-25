{lib}: let
  restructureService = host: serviceName: port: {
    inherit host;
    inherit port;
  };

  restructureHost = host: services:
    lib.mapAttrs (serviceName: port: restructureService host serviceName port) services;
in {
  restructure = input: let
    restructured = lib.mapAttrs restructureHost input;
  in
    builtins.foldl' (acc: next: acc // next) {} (builtins.attrValues restructured);

  formatMappingHttp = {
    host,
    port,
  }: "http://${host}:${builtins.toString port}";

  formatMapping = {
    host,
    port,
  }: "${host}:${builtins.toString port}";
}
