data "sops_file" "kv-insomnia" {
  source_file = "insomnia-enc.yaml"
  input_type  = "yaml"
}

resource "vault_mount" "insomnia" {
  path        = "insomnia"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount for insomnia"
}

resource "vault_kv_secret_v2" "keycloak_prod" {
  mount               = vault_mount.insomnia.path
  name                = "keycloak/prod"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      host = data.sops_file.kv-insomnia.data["keycloak.prod.host"]
    }
  )
}

resource "vault_kv_secret_v2" "keycloak_home" {
  mount               = vault_mount.insomnia.path
  name                = "keycloak/home"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      host = data.sops_file.kv-insomnia.data["keycloak.home.host"]
    }
  )
}

resource "vault_kv_secret_v2" "konnect_token_personal" {
  mount               = vault_mount.insomnia.path
  name                = "konnect_token/personal"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      data = data.sops_file.kv-insomnia.data["konnect_token.personal"]
    }
  )
}

resource "vault_kv_secret_v2" "konnect_token_system" {
  mount               = vault_mount.insomnia.path
  name                = "konnect_token/system"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      data = data.sops_file.kv-insomnia.data["konnect_token.system"]
    }
  )
}