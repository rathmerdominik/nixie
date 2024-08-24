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
        hashedPasswordFile = config.age.secrets.user-dominik.path;
        openssh.authorizedKeys.keys = let
          pubkeys = import ../pubkeys.nix;
        in (
          builtins.attrValues pubkeys.users
          ++ builtins.attrValues pubkeys.hosts
        );
        extraGroups = ["wheel" "docker"];
        linger = true;
      };
    };
  };
}
