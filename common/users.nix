{config, ...}: {
  age.secrets.user-dominik.file = ../secrets/user-dominik.age;

  users = {
    groups.dominik.gid = 1000;

    users = {
      root.hashedPassword = "!";
      dominik = {
        uid = 1000;
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.user-dominik.path;
        openssh.authorizedKeys.keys = builtins.attrValues (import ../pubkeys.nix).users;
        extraGroups = ["wheel"];
        linger = true;
        password = "dominik";
      };
    };
  };
}
