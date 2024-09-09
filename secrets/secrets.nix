with import ../pubkeys.nix; {
  "user-dominik.age".publicKeys = (builtins.attrValues users) ++ (builtins.attrValues hosts);

  "microbin.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "paperless-ngx.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "cloudflare-token.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "immich.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "homarr.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "mealie.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "postgres-sql.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];

  "mullvad.age".publicKeys = (builtins.attrValues users) ++ [hosts.neon];

  "mail-rathmer.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "pterodactyl-env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "vaultwarden-env.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "authentik.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];
  "discord-to-authentik.age".publicKeys = (builtins.attrValues users) ++ [hosts.krypton];

  "mail-hammerclock.age".publicKeys = (builtins.attrValues users) ++ [hosts.argon];
  "keycloak-database.age".publicKeys = (builtins.attrValues users) ++ [hosts.argon];
}
