{
  # xenon
  jellyfin = "xenon:8096";
  homarr = "xenon:7575";
  radarr = "xenon:7878";
  sonarr = "xenon:8989";
  wings = {
    daemon = "xenon:9595";
    sftp = "xenon:2022";
  };
  prowlarr = "xenon:9696";
  jellyseerr = "xenon:5055";

  # neon
  qbittorrent = "neon:8080";

  # krypton
  pterodactyl = "krypton:9393";
  vaultwarden = "krypton:8000";

  # argon
  keycloak = "argon:8443";
}
{lib, ...}: let
  restructureService = host: serviceName: port: {
    inherit host;
    inherit port;
  };

  restructureHost = host: services:
    lib.mapAttrs (serviceName: port: restructureService host serviceName port) services;

  restructure = input: let
    restructured = lib.mapAttrs restructureHost input;
  in
    builtins.foldl' (acc: next: acc // next) {} (builtins.attrValues restructured);
in
  # TODO: allles übertragen
  restructure {
    xenon = {
      jellyfin = 8096;
      sonarr = 8989;
    };
    neon = {
      qbittorrent = 8080;
    };
  }
