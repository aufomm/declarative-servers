{ config, ... }:
let
  hostname = "auth.li.lab";
  dbPassword = config.sops.secrets."keycloak/db-password".path;
in
{
  services.keycloak = {
    enable = true;
    database.createLocally = false;
    database.passwordFile = "${dbPassword}";
    database.type = "postgresql";
    initialAdminPassword = "veryconfusing";
    settings = {
      inherit hostname;
      http-enabled = true;
      http-host = "127.0.0.1";
      http-port = 8080;
      proxy-headers = "xforwarded";
    };
  };

  systemd.services."keycloak" = {
    after = [ "traefik.service" ];
    requires = [ "traefik.service" ];

    serviceConfig = {
      TimeoutStopSec = 5;
      RestartSec = 5;
    };
  };
}
