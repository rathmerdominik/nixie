with import ../pubkeys.nix; {
  "user-dominik.age".publicKeys = (builtins.attrValues users) ++ (builtins.attrValues hosts);

  "paperless-ngx.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "paperless-ngx-mail.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "immich.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "restic-xenon.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];

  "pterodactyl-env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "vaultwarden-env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "restic-krypton.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
}
