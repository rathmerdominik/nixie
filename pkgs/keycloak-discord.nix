# Big thanks to https://github.com/Conquerix/shulker/blob/f77374be06c5dbbd6445c54e74db7ce4a72a505f/nix/pkgs/keycloak-discord/default.nix
{
  stdenv,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "keycloak-discord";
  pauthor = "andythorne";
  version = "0.5.0";

  # Use a patched version that actually supports the newest keycloak version
  src = builtins.fetchFromGithub {
    owner = pauthor;
    repo = "https://github.com/andythorne/keycloak-discord";
    rev = "af9e5623f74b71530b1f6b9877faf0d50b50f8d2";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p "$out"
    install "$src" "$out/${pname}-${version}.jar"
  '';

  meta = with lib; {
    homepage = "https://github.com/wadahiro/keycloak-discord";
    description = "Keycloak Social Login extension for Discord";
    license = licenses.asl20;
    maintainers = with maintainers; [mkg20001];
  };
}
