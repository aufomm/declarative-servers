data "sops_file" "kv-secrets" {
  source_file = "secrets-enc.yaml"
  input_type  = "yaml"
}

resource "vault_mount" "secrets" {
  path        = "secrets"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "redis" {
  mount               = vault_mount.secrets.path
  name                = "redis"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      password = data.sops_file.kv-secrets.data["redis.password"]
    }
  )
}

resource "vault_kv_secret_v2" "kong_oidc_mesh" {
  mount               = vault_mount.secrets.path
  name                = "kong/oidc/mesh"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      session_secret = data.sops_file.kv-secrets.data["kong.oidc.session_secret"]
      client_secret  = data.sops_file.kv-secrets.data["kong.oidc.mesh.client_secret"]
    }
  )
}

resource "vault_kv_secret_v2" "mistral_auth_header" {
  mount               = vault_mount.secrets.path
  name                = "ai/mistral"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      auth_header = "Bearer ${data.sops_file.kv-secrets.data["ai.mistral_token"]}"
    }
  )
}

resource "vault_kv_secret_v2" "gemini_api_key" {
  mount               = vault_mount.secrets.path
  name                = "ai/gemini"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      api_key = data.sops_file.kv-secrets.data["ai.gemini_api_key"]
    }
  )
}

resource "vault_kv_secret_v2" "homelab_jwks" {
  mount               = vault_mount.secrets.path
  name                = "homelab/jwks"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      private = data.sops_file.kv-secrets.data["nginx_jwk.private"]
      public  = data.sops_file.kv-secrets.data["nginx_jwk.public"]
      idp     = data.sops_file.kv-secrets.data["nginx_jwk.idp"]
    }
  )
}

resource "vault_kv_secret_v2" "grafana_client_secret" {
  mount               = vault_mount.secrets.path
  name                = "homelab/grafana_client_secret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      data = data.sops_file.kv-secrets.data["oidc.grafana.client_secret"]
    }
  )
}

resource "vault_kv_secret_v2" "grafana_client_id" {
  mount               = vault_mount.secrets.path
  name                = "homelab/grafana_client_id"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      data = data.sops_file.kv-secrets.data["oidc.grafana.client_id"]
    }
  )
}

locals {
  cert_types = ["lan", "k8s", "hybrid", "lab", "cluster"]
}

# Use sops to decrypt each certificate and key file
data "sops_file" "leaf_cert" {
  for_each = toset(local.cert_types)

  source_file = "${path.module}/certs/${each.key}/cert-enc.bin"
  input_type  = "raw"
}

data "sops_file" "leaf_key" {
  for_each = toset(local.cert_types)

  source_file = "${path.module}/certs/${each.key}/key-enc.bin"
  input_type  = "raw"
}

resource "vault_kv_secret_v2" "certs" {
  for_each = toset(local.cert_types)

  mount = vault_mount.secrets.path
  name  = "certs/${each.key}"
  # Ensure only one version exists and prevent race conditions
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    certificate = data.sops_file.leaf_cert[each.key].raw
    key         = data.sops_file.leaf_key[each.key].raw
  })
}


locals {
  ca_types = ["k8s", "mesh"]
}

# Use sops to decrypt each certificate and key file
data "sops_file" "ca_cert" {
  for_each = toset(local.ca_types)

  source_file = "${path.module}/cas/${each.key}/cert-enc.bin"
  input_type  = "raw"
}

data "sops_file" "ca_key" {
  for_each = toset(local.ca_types)

  source_file = "${path.module}/cas/${each.key}/key-enc.bin"
  input_type  = "raw"
}

resource "vault_kv_secret_v2" "cas" {
  for_each = toset(local.ca_types)

  mount = vault_mount.secrets.path
  name  = "cas/${each.key}"
  # Ensure only one version exists and prevent race conditions
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    certificate = data.sops_file.ca_cert[each.key].raw
    key         = data.sops_file.ca_key[each.key].raw
  })
}
