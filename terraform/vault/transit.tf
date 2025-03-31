resource "vault_mount" "sops" {
  path        = "sops"
  type        = "transit"
  description = "Vault Transit for SOPS"
}

resource "vault_transit_secret_backend_key" "sops_key" {
  backend            = vault_mount.sops.path
  name               = "default"
  type               = "aes256-gcm96"
  auto_rotate_period = 2592000
  deletion_allowed   = false
}