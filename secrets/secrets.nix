with import ../pubkeys.nix; {
  "network/domain.age".publicKeys = (builtins.attrValues users) ++ (builtins.attrValues hosts);

  "users/dominik/mail.age".publicKeys = (builtins.attrValues users) ++ (builtins.attrValues hosts);
  "users/dominik/password.age".publicKeys = (builtins.attrValues users) ++ (builtins.attrValues hosts);

  "paperless-ngx/password.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "paperless-ngx/mail.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "immich/env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "pelican/env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "vaultwarden/env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "restic/krypton.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "forgejo/env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "forgejo/admin.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "forgejo/mail.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "forgejo/user.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "aiostreams/env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "hetzner/storage-user.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "hetzner/ipv6.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
}
