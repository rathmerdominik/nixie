{lib, ...}: {
  options.networking.mail-domain = lib.mkOption {type = lib.types.string;};
}
