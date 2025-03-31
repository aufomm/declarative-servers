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