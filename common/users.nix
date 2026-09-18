{config, ...}: let
  secretsPath = ../secrets/users;
  secretsDominikPath = "${secretsPath}/dominik";
in {
  age.secrets.users-dominik-password.file = "${secretsDominikPath}/password.age";
  age.secrets.users-dominik-mail.file = "${secretsDominikPath}/mail.age";

  users = {
    mutableUsers = false;
    groups.dominik.gid = 1000;

    users = {
      root.hashedPassword = "!";
      dominik = {
        uid = 1000;
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.users-dominik-password.path;
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
