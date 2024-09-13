{
  services.postgresql = {
    enable = true;
    ensureDatabases = ["paperless"];
    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
  };
}
