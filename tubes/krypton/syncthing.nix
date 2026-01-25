{...}: let
  storagePath = "/srv/big-storage/syncthing";
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
          id = "NL422EN-2HW56RJ-FOJOOJX-UACMSZM-J5FNAJP-75UMA2R-SPGIKS3-F5VOBQ6";
        };
        phone = {
          id = "V4DRUMH-QIPRPSR-J2RVQXQ-36EIU6L-E375YOX-CVJ6RSC-G7WN7T7-RC7GKAI";
        };
        laptop = {
          id = "YMZJLAW-A2MAMSI-O5EI6EO-LFAHGTO-WD6B2VC-R4WIBJ6-RDXJZSR-554Y4AP";
        };
        muos = {
          id = "SYLQS5A-4LFLVF3-DJ44KXY-UDVXL2H-KYWG2CH-MQLWSNY-GYGJ3SJ-RETSUQP";
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
        MuOS = {
          path = "${storagePath}/MuOS";
          id = "MuOS";
          devices = ["muos"];
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
