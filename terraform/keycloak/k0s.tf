resource "keycloak_openid_client" "k0s" {
  realm_id                     = keycloak_realm.terraform.id
  client_id                    = "k0s"
  name                         = "k0s"
  description                  = "Use this client for k0s cluster authn and authz"
  enabled                      = true
  access_type                  = "PUBLIC"
  # client_secret                = data.sops_file.secrets.data["k0s.client_secret"]
  service_accounts_enabled     = false
  standard_flow_enabled        = true
  pkce_code_challenge_method   = "S256"
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
  valid_redirect_uris = [
    "http://localhost:18000",
    "http://localhost:8000"
  ]
}

resource "keycloak_user" "k0s_admin" {
  realm_id       = keycloak_realm.terraform.id
  username       = "k0s-admin"
  enabled        = true
  email_verified = true
  email          = "k0s-admin@li.local"
  first_name     = "K0s"
  last_name      = "Admin"
  initial_password {
    value     = data.sops_file.secrets.data["users.k0s-admin.password"]
    temporary = false
  }
}

resource "keycloak_group" "k0s_cluster_admin" {
  realm_id = keycloak_realm.terraform.id
  name     = "system:masters"
}

resource "keycloak_group_memberships" "k0s_admin" {
  realm_id = keycloak_realm.terraform.id
  group_id = keycloak_group.k0s_cluster_admin.id

  members = [
    keycloak_user.k0s_admin.username,
    keycloak_user.fomm.username
  ]
}

resource "keycloak_openid_client_default_scopes" "k0s_default_scopes" {
  realm_id  = keycloak_realm.terraform.id
  client_id = keycloak_openid_client.k0s.id

  default_scopes = [
    "basic",
    "email",
    "profile",
    "offline_access",
    keycloak_openid_client_scope.groups_scope.name,
  ]
}

resource "keycloak_openid_client_optional_scopes" "k0s_optional_scopes" {
  realm_id  = keycloak_realm.terraform.id
  client_id = keycloak_openid_client.k0s.id

  optional_scopes = [
    "address",
    "phone",
    "microprofile-jwt",
    "organization",
  ]
}