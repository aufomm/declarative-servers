{ config, pkgs, ... }:
let
  hostname = "vault.li.lab";
  sslCert = config.sops.secrets."vault/ssl_certificate".path;
  sslCertKey = config.sops.secrets."vault/ssl_certificate_key".path;
in
{
  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    address = "[::]:8200";
    storageBackend = "file";
    storagePath = "/var/lib/vault";
    # This provides flexibility to have longer validity for tokens and secrets for some read-only roles.
    extraConfig = ''
      api_addr     = "https://${hostname}:8200"
      disable_clustering = true
      max_lease_ttl = "8760h"
      default_lease_ttl = "768h"
      ui           = true
    '';
    listenerExtraConfig = ''
      tls_min_version = "tls12"
      tls_disable_client_certs = true
    '';
    tlsCertFile = "${sslCert}";
    tlsKeyFile = "${sslCertKey}";
  };
}
