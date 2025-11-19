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
    extraConfig = ''
      api_addr     = "https://${hostname}:8200"
      disable_clustering = true
      ui           = true
    '';
    tlsCertFile = "${sslCert}";
    tlsKeyFile = "${sslCertKey}";
  };
}
