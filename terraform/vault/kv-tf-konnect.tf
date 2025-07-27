resource "vault_mount" "konnect" {
  path        = "konnect"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount for konnect"
}