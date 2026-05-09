/*
  This setup creates a adminless Keycloak.

  To create an admin user,we can use local port forwarding. (Make sure we set `https-port` to 8443 for the initial set up)

  For the initial setup, we can bind the https port to a local port (8443) using ssh port forwarding:
  ```bash
  ssh <keycloak_host> -L 8443:localhost:8443
  ```

  Once it is set up successfully, we can then use port 443.
*/
{ config, ... }:
let
  hostname = "auth.konghqps.com";
  dbPassword = config.sops.secrets."keycloak/db-password".path;
  homeCA = config.sops.secrets."fomm_ca".path;
in
{
  services.keycloak = {
    enable = true;
    database.createLocally = false;
    database.passwordFile = "${dbPassword}";
    database.type = "postgresql";
    settings = {
      inherit hostname;
      proxy-headers="xforwarded";
      http-enabled = true;
      http-port = 8080;
      https-trust-store-file = "${homeCA}";
      https-trust-store-type = "PEM";
      truststore-paths = "${homeCA}";
    };
  };
}
