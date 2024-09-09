{config, ...}: {
  age.secrets.postgres-sql.file = ../../secrets/postgres-sql.age;

  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "mealie"
    ];
    ensureUsers = [
      {
        name = "mealie";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
          createrole = true;
          bypassrls = true;
        };
      }
    ];
    enableJIT = true;
    initialScript = config.age.secrets.postgres-sql.path;
  };
}
