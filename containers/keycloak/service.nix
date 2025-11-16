/*
This setup creates a adminless Keycloak. To create an admin user,we can use local port forwarding.

```bash
ssh <keycloak_host> -L 9443:localhost:9443
```
*/
{ config, ... }:
let
  hostname = "auth.li.lab";
  dbPassword = config.sops.secrets."keycloak/db-password".path;
  sslCert = config.sops.secrets."keycloak/ssl_certificate".path;
  sslCertKey = config.sops.secrets."keycloak/ssl_certificate_key".path;
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
      https-port = 9443;
      https-certificate-file = "${sslCert}";
      https-certificate-key-file = "${sslCertKey}";
      https-trust-store-file = "${homeCA}";
      https-trust-store-type = "PEM";
      https-client-auth = "request";
    };
  };

  networking.firewall.allowedTCPPorts = [
    9443
  ];
}
