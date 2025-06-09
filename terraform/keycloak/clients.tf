resource "keycloak_openid_client" "assertion" {
  realm_id                  = keycloak_realm.terraform.id
  client_id                 = "assertion"
  name                      = "assertion"
  description               = "Use client assertion for authentication"
  enabled                   = true
  access_type               = "CONFIDENTIAL"
  service_accounts_enabled  = true
  client_authenticator_type = "client-jwt"
  extra_config = {
    "token.endpoint.auth.signing.alg" = "RS256"
    "jwks.url"                        = data.sops_file.secrets.data["assertion.jwk_url"]
    "use.jwks.url"                    = "true"
  }
}

resource "keycloak_openid_client" "vault" {
  realm_id    = keycloak_realm.terraform.id
  client_id   = "vault"
  name        = "lab-vault-login"
  description = "A client for homelab vault OIDC log in"
  enabled     = true
  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://vault.li.lab:8200/ui/vault/auth/oidc/oidc/callback"
  ]
  web_origins = [
    "https://vault.li.lab:8200"
  ]
  service_accounts_enabled  = true
  client_secret             = data.sops_file.secrets.data["vault.client_secret"]
  standard_flow_enabled     = true
  client_authenticator_type = "client-secret"
}

resource "keycloak_openid_client" "sliver" {
  realm_id    = keycloak_realm.terraform.id
  client_id   = "sliver"
  name        = "konnect-sliver-testing"
  description = "Test Konnect sliver project"
  enabled     = true
  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "http://localhost/callback"
  ]
  service_accounts_enabled     = true
  direct_access_grants_enabled = true
  implicit_flow_enabled        = true
  client_secret                = data.sops_file.secrets.data["sliver.client_secret"]
  standard_flow_enabled        = true
  client_authenticator_type    = "client-secret"
}

resource "keycloak_openid_client" "hcv-jwt" {
  realm_id    = keycloak_realm.terraform.id
  client_id   = "hcv-jwt"
  name        = "hcv-vault-jwt"
  description = "Test jwt auth with hashicorp vault"
  enabled     = true
  access_type = "CONFIDENTIAL"

  service_accounts_enabled     = true
  direct_access_grants_enabled = false
  implicit_flow_enabled        = false
  client_secret                = data.sops_file.secrets.data["hcv_jwt.client_secret"]
  standard_flow_enabled        = false
  client_authenticator_type    = "client-secret"
}