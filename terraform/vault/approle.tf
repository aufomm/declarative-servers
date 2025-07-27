resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "insomnia_readonly" {
  backend        = vault_auth_backend.approle.path
  role_name      = "insomnia_readonly_role"
  role_id        = data.sops_file.kv-secrets.data["approle.insomnia.role_id"]
  token_policies = ["insomnia_readonly_policy"]
}

resource "vault_approle_auth_backend_role_secret_id" "insomnia_readonly" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.insomnia_readonly.role_name
  secret_id = data.sops_file.kv-secrets.data["approle.insomnia.secret_id"]
}

resource "vault_approle_auth_backend_role" "k0s_readonly" {
  backend        = vault_auth_backend.approle.path
  role_name      = "k0s_readonly_role"
  role_id        = data.sops_file.kv-secrets.data["approle.k0s.role_id"]
  token_policies = ["secrets_readonly_policy"]
}

resource "vault_approle_auth_backend_role_secret_id" "k0s_readonly" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.k0s_readonly.role_name
  secret_id = data.sops_file.kv-secrets.data["approle.k0s.secret_id"]
}

resource "vault_approle_auth_backend_role" "rock_readonly" {
  backend        = vault_auth_backend.approle.path
  role_name      = "rock_readonly_role"
  role_id        = data.sops_file.kv-secrets.data["approle.rock.role_id"]
  token_policies = ["secrets_readonly_policy"]
}

resource "vault_approle_auth_backend_role_secret_id" "rock_readonly" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.rock_readonly.role_name
  secret_id = data.sops_file.kv-secrets.data["approle.rock.secret_id"]
}

resource "vault_approle_auth_backend_role" "konnect_readonly" {
  backend        = vault_auth_backend.approle.path
  role_name      = "konnect_readonly_role"
  role_id        = data.sops_file.kv-secrets.data["approle.konnect_readonly.role_id"]
  token_policies = ["konnect_readonly"]
}

resource "vault_approle_auth_backend_role_secret_id" "konnect_readonly" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.konnect_readonly.role_name
  secret_id = data.sops_file.kv-secrets.data["approle.konnect_readonly.secret_id"]
}

resource "vault_approle_auth_backend_role" "konnect_admin" {
  backend        = vault_auth_backend.approle.path
  role_name      = "konnect_admin_role"
  role_id        = data.sops_file.kv-secrets.data["approle.konnect_admin.role_id"]
  token_policies = ["konnect_admin"]
}

resource "vault_approle_auth_backend_role_secret_id" "konnect_admin" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.konnect_admin.role_name
  secret_id = data.sops_file.kv-secrets.data["approle.konnect_admin.secret_id"]
}