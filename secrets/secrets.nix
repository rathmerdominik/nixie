with import ../pubkeys.nix; {
  "user-dominik.age".publicKeys = (builtins.attrValues users) ++ (builtins.attrValues hosts);

  "paperless-ngx.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "paperless-ngx-mail.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "immich.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "pterodactyl-env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "vaultwarden-env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "restic-krypton.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
}
