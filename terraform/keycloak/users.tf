resource "keycloak_user" "vault-admin" {
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

resource "keycloak_user" "test-user" {
  realm_id = keycloak_realm.terraform.id
  username = "test-user"
  enabled  = true

  email      = "test-user@li.local"
  first_name = "Test"
  last_name  = "User"
  initial_password {
    value     = data.sops_file.secrets.data["users.test-user.password"]
    temporary = false
  }
}