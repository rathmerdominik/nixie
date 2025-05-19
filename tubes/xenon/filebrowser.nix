{
  proxy-ports,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.filebrowser;
  inherit (lib) types;
  format = pkgs.formats.json {};
  defaultUser = "filebrowser";
  defaultGroup = "filebrowser";
in {
  options = {
    services.filebrowser = {
      enable = true;
      package = pkgs.filebrowser;
      user = defaultUser;
      group = defaultGroup;
      openFirewall = true;
      settings = {
        address = "0.0.0.0";
        port = proxy-ports.filebrowser.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.filebrowser = {
      after = ["network.target"];
      description = "FileBrowser";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} --config ${format.generate "config.json" cfg.settings}";

        User = cfg.user;
        Group = cfg.group;

        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "filebrowser";
      };
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.settings.port];
    users = {
      users.${cfg.user} = lib.mkIf (cfg.user == defaultUser) {
        group = cfg.group;
        isSystemUser = true;
      };
      groups.${cfg.group} = lib.mkIf (cfg.group == defaultGroup) {};
    };
  };
}
