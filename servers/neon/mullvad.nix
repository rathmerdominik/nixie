{
  config,
  lib,
  ...
}: {
  services.mullvad-vpn.enable = true;

  systemd.services.mullvad-install = {
    script = let
      mullvad = lib.getExe config.services.mullvad-vpn.package;
    in ''
      ${mullvad} account set "$(cat ${config.age.secrets.mullvad.path})"
      ${mullvad} relay set location nl
      ${mullvad} connect
      ${mullvad} auto-connect set on
      ${mullvad} lan set allow
    '';
    after = ["mullvad-vpn.service"];
    requires = ["mullvad-vpn.service"];
  };
}
