{
  pkgs,
  ...
}:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = false;
    package = pkgs.postgresql_16;
    extensions = [
      pkgs.postgresql_16.pkgs.pgvector
    ];

    settings.port = 5432;
    authentication = pkgs.lib.mkOverride 10 ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';

    ensureDatabases = [
      "keycloak"
    ];
    ensureUsers = [
      {
        name = "fomm";
        ensureClauses.login = true;
        ensureClauses.superuser = true;
      }
      {
        name = "keycloak";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
    ];
  };
}
