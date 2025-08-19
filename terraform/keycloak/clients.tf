locals {
  domains = {
    "vault"   = "vault.li.lab:8200"
    "grafana" = "grafana.li.k0s"
    "argocd"  = "argo.li.k0s"
    "mesh"    = "mesh.li.k0s"
    "orders"  = "orders.li.k0s"
  }
}

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
    "https://${local.domains.vault}/ui/vault/auth/oidc/oidc/callback"
  ]
  web_origins = [
    "https://${local.domains.vault}"
  ]
  service_accounts_enabled  = false
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

resource "keycloak_openid_client" "grafana" {
  realm_id    = keycloak_realm.terraform.id
  client_id   = "grafana"
  name        = "lab-grafana-login"
  description = "A client for homelab grafana OIDC log in"
  enabled     = true
  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://${local.domains.grafana}/login/generic_oauth"
  ]
  web_origins = [
    "https://${local.domains.grafana}"
  ]
  service_accounts_enabled     = false
  client_secret                = data.sops_file.secrets.data["grafana.client_secret"]
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
}

resource "keycloak_openid_client" "argocd" {
  realm_id    = keycloak_realm.terraform.id
  client_id   = "argocd"
  name        = "lab-argocd-login"
  description = "A client for homelab argocd OIDC log in"
  enabled     = true
  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://${local.domains.argocd}/auth/callback",
  ]
  web_origins = [
    "https://${local.domains.argocd}"
  ]
  valid_post_logout_redirect_uris = [
    "https://${local.domains.argocd}/applications"
  ]
  service_accounts_enabled     = false
  client_secret                = data.sops_file.secrets.data["argocd.client_secret"]
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
}

resource "keycloak_openid_client" "mesh-cp" {
  realm_id    = keycloak_realm.terraform.id
  client_id   = "mesh-cp"
  name        = "lab-mesh-cp-login"
  description = "A client for homelab mesh cp OIDC log in via kong"
  enabled     = true
  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://${local.domains.mesh}",
    "https://${local.domains.mesh}/",
    "https://${local.domains.mesh}/*"
  ]
  web_origins = [
    "https://${local.domains.mesh}"
  ]
  service_accounts_enabled = false
  client_secret            = data.sops_file.secrets.data["mesh.client_secret"]
  standard_flow_enabled    = true
  implicit_flow_enabled    = false
}

resource "keycloak_openid_client" "orders-frontend" {
  realm_id    = keycloak_realm.terraform.id
  client_id   = "orders"
  name        = "lab-orders-frontend-login"
  description = "A client for homelab orders tracking OIDC log in via kong"
  enabled     = true
  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://${local.domains.orders}/",
  ]
  web_origins = [
    "https://${local.domains.orders}"
  ]
  service_accounts_enabled = false
  client_secret            = data.sops_file.secrets.data["orders.client_secret"]
  standard_flow_enabled    = true
  implicit_flow_enabled    = false
}

resource "keycloak_openid_client" "mtls" {
  realm_id    = keycloak_realm.terraform.id
  client_id   = "mtls"
  name        = "lab-mtls-cbat"
  description = "A client for testing client auth with keycloak"
  enabled     = true
  access_type = "CONFIDENTIAL"
  service_accounts_enabled = true
  client_authenticator_type = "client-x509"
  extra_config = {
    # "x509.subjectdn" = ".*CN=fomm-kc-mtls.*"
    "x509.subjectdn" = "CN=fomm-kc-mtls, O=foMM Ltd, L=Melbourne, ST=Victoria, C=AU"
    # openssl x509 -subject -noout -in cert.pem -nameopt rfc2253,sep_comma_plus_space
    "tls.client.certificate.bound.access.tokens" = "true"
  }
}