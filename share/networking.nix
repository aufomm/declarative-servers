{
  networking = {
    hosts = {
      "192.168.3.172" = [
        "vault.li.lab"
      ];
      "192.168.3.174" = [
        "proxy.li.lab"
      ];
      "192.168.3.100" = [
        "traefik.li.lab"
        "auth.li.lab"
        "minio.li.lab"
        "redis.li.lab"
        "pg.li.lab"
      ];
      "192.168.3.162" = [
        "proxy.li.rock"
      ];
    };
  };
}
