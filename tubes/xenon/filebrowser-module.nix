{
  config,
  pkgs,
  lib,
  utils,
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
      enable = lib.mkEnableOption "FileBrowser";

      package = lib.mkPackageOption pkgs "filebrowser" {};

      user = lib.mkOption {
        type = types.str;
        default = defaultUser;
        description = ''
          The name of the user account under which FileBrowser should run.
        '';
      };

      group = lib.mkOption {
        type = types.str;
        default = defaultGroup;
        description = ''
          The name of the user group under which FileBrowser should run.
        '';
      };

      openFirewall = lib.mkOption {
        default = false;
        description = ''
          Whether to automatically open the ports for FileBrowser in the firewall.
        '';
        type = types.bool;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/filebrowser";
        description = ''
          The directory where FileBrowser stores its state.
        '';
        type = types.path;
      };

      dataDir = lib.mkOption {
        default = "${cfg.stateDir}/data";
        defaultText = lib.literalExpression ''
          "''${config.services.filebrowser.stateDir}/data"
        '';
        description = ''
          The directory where FileBrowser stores files.
        '';
        type = types.path;
      };

      cacheDir = lib.mkOption {
        default = null;
        description = ''
          The directory where FileBrowser stores its cache.
        '';
        type = types.nullOr types.path;
      };

      database = lib.mkOption {
        default = "${cfg.stateDir}/database.db";
        defaultText = lib.literalExpression ''
          "''${config.services.filebrowser.stateDir}/database.db"
        '';
        description = ''
          The path to FileBrowser's database.
        '';
        type = types.path;
      };

      settings = lib.mkOption {
        default = {};
        description = ''
          Settings for FileBrowser.
          Refer to <https://filebrowser.org/cli/filebrowser-config-set> for supported values.
        '';
        type = types.submodule {
          freeformType = format.type;
          options = {
            address = lib.mkOption {
              default = "0.0.0.0";
              description = ''
                The address to listen on.
              '';
              type = types.str;
            };
            port = lib.mkOption {
              default = 8080;
              description = ''
                The port to listen on.
              '';
              type = types.port;
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.filebrowser = {
        after = ["network.target"];
        description = "FileBrowser";
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          ExecStart = let
            args =
              [
                (lib.getExe cfg.package)
                "--config"
                (format.generate "config.json" cfg.settings)
                "--database"
                cfg.database
              ]
              ++ (lib.optionals (cfg.cacheDir != null) [
                "--cache-dir"
                cfg.cacheDir
              ]);
          in
            utils.escapeSystemdExecArgs args;

          StateDirectory = cfg.stateDir;
          WorkingDirectory = cfg.dataDir;

          User = cfg.user;
          Group = cfg.group;

          NoNewPrivileges = true;
          PrivateDevices = true;
          ProtectSystem = "full";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          MemoryDenyWriteExecute = true;
          LockPersonality = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          PrivateTmp = true;
          DevicePolicy = "closed";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
        };
      };

      tmpfiles.settings.filebrowser =
        lib.genAttrs
        (
          [
            cfg.stateDir
            cfg.dataDir
            (builtins.dirOf cfg.database)
          ]
          ++ (lib.optional (cfg.cacheDir != null) cfg.cacheDir)
        )
        (_: {
          d = {
            inherit (cfg) user group;
            mode = "0700";
          };
        });
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.settings.port];

    users = {
      users.${cfg.user} = lib.mkIf (cfg.user == defaultUser) {
        home = cfg.dataDir;
        group = cfg.group;
        isSystemUser = true;
      };
      groups.${cfg.group} = lib.mkIf (cfg.group == defaultGroup) {};
    };
  };

  meta.maintainers = [
    lib.maintainers.lukaswrz
  ];
}
