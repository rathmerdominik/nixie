{
  config,
  lib,
  ...
}: {
  age.secrets.mullvad.file = ../../secrets/mullvad.age;

  services.mullvad-vpn.enable = true;

  # systemd.services.mullvad-install = {
  #   script = let
  #     mullvad = lib.getExe' config.services.mullvad-vpn.package "mullvad";
  #   in ''
  #     ${mullvad} account set "$(cat ${config.age.secrets.mullvad.path})"
  #     ${mullvad} relay set location nl
  #     ${mullvad} connect
  #     ${mullvad} auto-connect set on
  #     ${mullvad} lan set allow
  #   '';
  #   wantedBy = ["mullvad-daemon.service"];
  #   after = ["mullvad-daemon.service"];
  #   requires = ["mullvad-daemon.service"];
  # };

  systemd.services.mullvad-daemon.postStart = let
    mullvad = lib.getExe' config.services.mullvad-vpn.package "mullvad";
  in ''
    ${mullvad} account login "$(cat ${config.age.secrets.mullvad.path})"
    ${mullvad} relay set location nl
    ${mullvad} connect
    ${mullvad} auto-connect set on
    ${mullvad} lan set allow
  '';
}
