{
  pkgs,
  ...
}:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
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
      host    ai              ai-admin        192.168.3.0/24          scram-sha-256
      host    fomm_blog_rag   ai-admin        192.168.3.0/24          scram-sha-256
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

  networking.firewall.allowedTCPPorts = [
    5432
  ];
}
