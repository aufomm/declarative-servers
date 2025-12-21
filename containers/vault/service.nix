{ config, pkgs, ... }:
let
  hostname = "vault.li.demo";
  sslCert = config.sops.secrets."vault/ssl_certificate".path;
  sslCertKey = config.sops.secrets."vault/ssl_certificate_key".path;
in
{
  # disable_mlock = true is required when running Vault inside a container
  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    address = "[::]:8200";
    storageBackend = "file";
    storagePath = "/var/lib/vault";
    extraConfig = ''
      api_addr     = "https://${hostname}:8200"
      disable_clustering = true
      ui           = true
      disable_mlock = true
    '';
    listenerExtraConfig = ''
      tls_min_version = "tls12"
      tls_disable_client_certs = true
    '';
    tlsCertFile = "${sslCert}";
    tlsKeyFile = "${sslCertKey}";
  };
}
