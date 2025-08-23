{pkgs, ...}: {
  services.postgresql = {
    enable = true;
    ensureDatabases = ["paperless"];
    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };
}
