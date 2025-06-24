{
  networking = {
    hostName = "tools";
    useNetworkd = true;
    hosts = {
      "192.168.3.100" = [
        "traefik.li.lab"
        "auth.li.lab"
        "minio-console.li.lab"
        "minio.li.lab"
        "vault.li.lab"
        "redis.li.lab"
      ];
      "192.168.3.162" = [
        "traefik.li.rock"
        "kong.li.rock"
      ];
    };
  };
}
