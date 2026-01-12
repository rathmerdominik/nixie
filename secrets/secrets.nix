with import ../pubkeys.nix; {
  "user-dominik.age".publicKeys = (builtins.attrValues users) ++ (builtins.attrValues hosts);

  "paperless-ngx.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "paperless-ngx-mail.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "immich.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "pelican-env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "vaultwarden-env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "restic-krypton.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "forgejo.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
}
