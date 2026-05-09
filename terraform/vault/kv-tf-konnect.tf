data "sops_file" "kv-au-lxc" {
  source_file = "cp-secrets/au-lxc.yaml"
  input_type  = "yaml"
}

resource "vault_mount" "konnect" {
  path        = "konnect"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount for konnect"
}

resource "vault_kv_secret_v2" "zai_auth_header" {
  mount               = vault_mount.konnect.path
  name                = "au/lxc/ai/zai"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      auth_header = data.sops_file.kv-au-lxc.data["ai.zai.auth_header"]
    }
  )
}

resource "vault_kv_secret_v2" "weather_api" {
  mount               = vault_mount.konnect.path
  name                = "au/lxc/weather_api"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      apikey = data.sops_file.kv-au-lxc.data["weather_api.apikey"]
    }
  )
}

resource "vault_kv_secret_v2" "mcp_private_client" {
  mount               = vault_mount.konnect.path
  name                = "au/lxc/ai/mcp/private_client"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      id     = data.sops_file.kv-au-lxc.data["ai.mcp.private_client.id"]
      secret = data.sops_file.kv-au-lxc.data["ai.mcp.private_client.secret"]
    }
  )
}
