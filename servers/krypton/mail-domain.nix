{lib, ...}: {
  options.networking.mail-domain = lib.mkOption {type = lib.types.str;};
  options.networking.fqdn-mail-domain = lib.mkOption {type = lib.types.str;};
}
