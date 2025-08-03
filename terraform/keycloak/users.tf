resource "keycloak_user" "vault-admin" {
  realm_id       = keycloak_realm.terraform.id
  username       = "vault-admin"
  enabled        = true
  email_verified = true
  email          = "vault-admin@li.local"
  first_name     = "Vault"
  last_name      = "Admin"
  initial_password {
    value     = data.sops_file.secrets.data["users.vault-admin.password"]
    temporary = false
  }
}

resource "keycloak_user" "fomm" {
  realm_id       = keycloak_realm.terraform.id
  username       = "fomm"
  enabled        = true
  email_verified = true
  email          = "admin@li.local"
  first_name     = "All"
  last_name      = "Admin"
  initial_password {
    value     = data.sops_file.secrets.data["users.fomm.password"]
    temporary = false
  }
}

resource "keycloak_user" "test-user" {
  realm_id       = keycloak_realm.terraform.id
  username       = "test-user"
  enabled        = true
  email_verified = true
  email          = "test-user@li.local"
  first_name     = "Test"
  last_name      = "User"
  initial_password {
    value     = data.sops_file.secrets.data["users.test-user.password"]
    temporary = false
  }
}

resource "keycloak_user" "grafana-admin" {
  realm_id       = keycloak_realm.terraform.id
  username       = "grafana-admin"
  enabled        = true
  email_verified = true
  email          = "grafana-admin@li.local"
  first_name     = "grafana"
  last_name      = "Admin"
  initial_password {
    value     = data.sops_file.secrets.data["users.grafana-admin.password"]
    temporary = false
  }
}

resource "keycloak_user" "argocd-admin" {
  realm_id       = keycloak_realm.terraform.id
  username       = "argocd-admin"
  enabled        = true
  email_verified = true
  email          = "argocd-admin@li.local"
  first_name     = "argocd"
  last_name      = "Admin"
  initial_password {
    value     = data.sops_file.secrets.data["users.argocd-admin.password"]
    temporary = false
  }
}
