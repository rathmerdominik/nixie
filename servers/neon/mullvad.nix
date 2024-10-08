{
  config,
  lib,
  ...
}: {
  age.secrets.mullvad.file = ../../secrets/mullvad.age;

  services.mullvad-vpn.enable = true;

  systemd.services.mullvad-daemon.postStart = let
    mullvad = lib.getExe' config.services.mullvad-vpn.package "mullvad";
  in ''
    if ! ${mullvad} account list-devices; then
      ${mullvad} account login "$(cat ${config.age.secrets.mullvad.path})"
      ${mullvad} relay set location nl
      ${mullvad} connect
      ${mullvad} auto-connect set on
      ${mullvad} lan set allow
    fi
  '';
}
