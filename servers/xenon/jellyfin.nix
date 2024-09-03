{
  pkgs,
  config,
  ...
}: {
  services.jellyfin = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  nixpkgs.overlays = [
    (
      final: prev: {
        jellyfin-web = prev.jellyfin-web.overrideAttrs (finalAttrs: previousAttrs: {
          installPhase = ''
            runHook preInstall

            # this is the important line
            sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

            mkdir -p $out/share
            cp -a dist $out/share/jellyfin-web

            runHook postInstall
          '';
        });
      }
    )
  ];

  services.nginx.virtualHosts = let
    inherit (config.networking) domain;
  in {
    "watch.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;

      locations."/" = {
        proxyPass = "http://localhost:8096";
        extraConfig = ''
          proxy_buffering off;
        '';
      };

      locations."/socket" = {
        proxyWebsockets = true;
        proxyPass = "http://localhost:8096";
      };
    };
  };
}
