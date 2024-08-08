with import ../pubkeys.nix; {
  "user-dominik.age".publicKeys = (builtins.attrValues users) ++ (builtins.attrValues hosts);
  "microbin.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
  "paperless-ngx.age".publicKeys = (builtins.attrValues users) ++ [hosts.xenon];
}
