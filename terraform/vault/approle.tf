locals {
  approle_roles = {
    insomnia_readonly = {
      role_name      = "insomnia_readonly_role"
      token_policies = [vault_policy.readonly["insomnia"].name]
    }
    k0s_readonly = {
      role_name      = "k0s_readonly_role"
      token_policies = [vault_policy.readonly["secrets"].name]
    }
    konnect_readonly = {
      role_name      = "konnect_readonly_role"
      token_policies = [vault_policy.readonly["konnect"].name]
    }
    konnect_admin = {
      role_name = "konnect_admin_role"
      token_policies = [
        vault_policy.konnect_admin.name,
        vault_policy.konnect_policy_admin.name
      ]
    }
  }
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "approle_roles" {
  for_each = local.approle_roles

  backend        = vault_auth_backend.approle.path
  role_name      = each.value.role_name
  role_id        = data.sops_file.kv-secrets.data["approle.${each.key}.role_id"]
  token_policies = each.value.token_policies

  depends_on = [vault_auth_backend.approle]
}

resource "vault_approle_auth_backend_role_secret_id" "approle_secrets" {
  for_each = local.approle_roles

  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.approle_roles[each.key].role_name
  secret_id = data.sops_file.kv-secrets.data["approle.${each.key}.secret_id"]

  depends_on = [vault_approle_auth_backend_role.approle_roles]
}
