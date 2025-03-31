resource "vault_mount" "ecc" {
  path                      = "ecc"
  type                      = "pki"
  default_lease_ttl_seconds = 7776000  # 90 days
  max_lease_ttl_seconds     = 31622400 # 1 year

  allowed_response_headers = [
    "Last-Modified",
    "Location",
    "Replay-Nonce",
    "Link"
  ]

  passthrough_request_headers = [
    "If-Modified-Since"
  ]

}

data "sops_file" "vault_ecc_key" {  
  source_file = "${path.module}/cas/vault-ecc/key-enc.bin"
  input_type = "raw"
}

resource "vault_pki_secret_backend_config_ca" "ecc_ca" {
  backend    = vault_mount.ecc.path
  pem_bundle = data.sops_file.vault_ecc_key.raw
}

resource "vault_pki_secret_backend_role" "ecc_certmanager_role" {
  backend                     = vault_mount.ecc.path
  name                        = "certmanager"
  ttl                         = 31622400
  not_before_duration         = "1m"
  allow_ip_sans               = true
  allow_subdomains            = true
  allow_localhost             = true
  allow_bare_domains          = true
  allow_any_name              = true
  allow_wildcard_certificates = true
  allow_glob_domains          = true
  server_flag                 = true
  client_flag                 = true
  key_usage                   = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
  ext_key_usage               = ["ClientAuth", "ServerAuth"]
  key_type                    = "ec"
  key_bits                    = 256
  use_csr_common_name         = true
  use_csr_sans                = true
  organization                = ["foMM Ltd"]
  country                     = ["Australia"]
  locality                    = ["Melbourne"]
  province                    = ["Victoria"]
}

resource "vault_pki_secret_backend_config_cluster" "ecc_config_cluster" {
  backend  = vault_mount.ecc.path
  path     = "https://vault.li.lab:8200/v1/ecc"
  aia_path = "https://vault.li.lab:8200/v1/ecc"
}

resource "vault_pki_secret_backend_config_acme" "ecc" {
  backend                  = vault_mount.ecc.path
  enabled                  = true
  allowed_issuers          = ["*"]
  allowed_roles            = ["*"]
  allow_role_ext_key_usage = false
  default_directory_policy = "sign-verbatim"
  dns_resolver             = ""
  eab_policy               = "not-required"
}