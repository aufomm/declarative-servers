resource "keycloak_user" "user" {
  realm_id = keycloak_realm.terraform.id
  username = "vault-admin"
  enabled  = true

  email      = "vault-admin@li.local"
  first_name = "Vault"
  last_name  = "Admin"
  initial_password {
    value     = data.sops_file.secrets.data["users.vault-admin.password"]
    temporary = false
  }
}