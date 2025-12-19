/*
  This setup creates a adminless Keycloak. 
  
  To create an admin user,we can use local port forwarding.

  For the initial setup, we can bind the https port to a local port (9443) using ssh port forwarding:
  ```bash
  ssh <keycloak_host> -L 9443:localhost:9443
  ```

  Once it is set up successfully, we can then use port 443.
*/
{ config, ... }:
let
  hostname = "auth.li.lab";
  dbPassword = config.sops.secrets."keycloak/db-password".path;
  # Use ACME certificates instead of sops-managed ones
  acmeCertDir = config.security.acme.certs."${hostname}".directory;
  sslCert = "${acmeCertDir}/fullchain.pem";
  sslCertKey = "${acmeCertDir}/key.pem";
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
      https-port = 443;
      https-certificate-file = "${sslCert}";
      https-certificate-key-file = "${sslCertKey}";
      https-trust-store-file = "${homeCA}";
      https-trust-store-type = "PEM";
      https-client-auth = "request";
    };
  };

  networking.firewall.allowedTCPPorts = [
    443
  ];
}
