{mylib}:
mylib.restructure {
  xenon = {
    wings-sftp = 2022;
    jellyseerr = 5055;
    homarr = 7575;
    jellyfin = 8096;
    wings = 9595;
    immich = 2283;
    mealie = 9000;
  };

  neon = {
  };

  krypton = {
    vaultwarden = 8000;
    pterodactyl = 9393;
    authentik = 9070;
    # All of these go through the auth provider
    sonarr = 9070;
    radarr = 9070;
    prowlarr = 9070;
    qbit = 9070;
    microbin = 9070;
  };

  argon = {
    keycloak-https = 8443;
    keycloak-http = 880;
  };
}
