{
  pkgs,
  appimageTools,
  ...
}: let
  pname = "stremio-enhanced";
  version = "1.0.2";

  src = pkgs.fetchurl {
    url = "https://github.com/REVENGE977/${pname}/releases/download/v${version}/Stremio.Enhanced-${version}.AppImage";
    sha256 = "sha256:ae747e77b7851c03d154e9e95452297568ed35f2e322ad5fe2ecbba6b2c11f3a";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      substituteInPlace $out/stremio-enhanced.desktop --replace-fail 'Exec=AppRun' 'Exec=${pname}'
    '';
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/stremio-enhanced.desktop $out/share/applications/stremio-enhanced.desktop
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/stremio-enhanced.png \
        $out/share/icons/hicolor/512x512/apps/stremio-enhanced.png
    '';
  }
