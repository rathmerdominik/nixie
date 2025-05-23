{...}: let
  storagePath = "/srv/disks/mass-storage/Syncthing";
in {
  systemd.tmpfiles.settings."10-syncthing" = {
    storagePath.d = {
      user = "syncthing";
      group = "syncthing";
      mode = "0755";
    };
    "${storagePath}/Documents".d = {
      user = "syncthing";
      group = "syncthing";
      mode = "0755";
    };
    "${storagePath}/Projects".d = {
      user = "syncthing";
      group = "syncthing";
      mode = "0755";
    };
  };

  services.syncthing = {
    enable = true;
    relay.enable = true;
    openDefaultPorts = true;
    dataDir = storagePath;
    guiAddress = "0.0.0.0:8384";
    settings = {
      devices = {
        linpc = {
          id = "W66ACIQ-6D2WDZD-42A32Q7-3ZYUF5C-LTGPS2L-W2RDKVC-OOEBEHA-KNDJ4QF";
        };
        phone = {
          id = "V4DRUMH-QIPRPSR-J2RVQXQ-36EIU6L-E375YOX-CVJ6RSC-G7WN7T7-RC7GKAI";
        };
        laptop = {
          id = "YMZJLAW-A2MAMSI-O5EI6EO-LFAHGTO-WD6B2VC-R4WIBJ6-RDXJZSR-554Y4AP";
        };
      };
      folders = {
        Documents = {
          path = "${storagePath}/Documents";
          id = "Documents";
          devices = ["linpc" "phone" "laptop"];
        };
        Projects = {
          path = "${storagePath}/Projects";
          id = "Projects";
          devices = ["linpc" "laptop"];
        };
      };
      options = {
        urAccepted = 1;
        relaysEnabled = true;
        localAnnounceEnabled = true;
        localAnnouncePort = 21027;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [8384];
}
