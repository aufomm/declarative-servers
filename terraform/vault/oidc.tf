resource "vault_jwt_auth_backend" "oidc" {
  path               = "oidc"
  type               = "oidc"
  default_role       = "admin"
  oidc_discovery_url = "https://auth.li.lab/realms/terraform"
  oidc_client_id     = data.sops_file.kv-secrets.data["oidc.client_id"]
  oidc_client_secret = data.sops_file.kv-secrets.data["oidc.client_secret"]
  namespace_in_state = true
}

resource "vault_jwt_auth_backend_role" "admin" {
  backend        = vault_jwt_auth_backend.oidc.path
  role_name      = "admin"
  token_policies = ["admin"]
  user_claim     = "preferred_username"
  bound_claims = {
    "preferred_username" = "vault-admin"
  }
  role_type = "oidc"
  allowed_redirect_uris = [
    "https://vault.li.lab:8200/ui/vault/auth/oidc/oidc/callback"
  ]
}

resource "vault_jwt_auth_backend" "hcv_jwt" {
  path               = "jwt"
  description        = "Use Keycloak specific client to authenticate with hashicorp vault via JWT"
  type               = "jwt"
  default_role       = "jwt_secret_readonly"
  oidc_discovery_url = "https://auth.li.lab/realms/terraform"
  bound_issuer       = "https://auth.li.lab/realms/terraform"
}

resource "vault_jwt_auth_backend_role" "hcv_jwt_secret_readonly" {
  backend         = vault_jwt_auth_backend.hcv_jwt.path
  role_name       = "jwt_secret_readonly"
  token_policies  = ["secrets_readonly_policy"]
  user_claim      = "azp"
  bound_audiences = ["account"]
  bound_claims = {
    "azp" = data.sops_file.kv-secrets.data["hcv_jwt.client_id"]
  }
  role_type = "jwt"
}