{config, ...}: {
  age.secrets.user-dominik.file = ../secrets/user-dominik.age;

  users = {
    mutableUsers = false;
    groups.dominik.gid = 1000;

    users = {
      root.hashedPassword = "!";
      dominik = {
        uid = 1000;
        isNormalUser = true;
        # hashedPasswordFile = config.age.secrets.user-dominik.path;
        password = "dominik";
        openssh.authorizedKeys.keys = builtins.attrValues (import ../pubkeys.nix).users;
        extraGroups = ["wheel" "podman"];
        linger = true;
      };
    };
  };
}
