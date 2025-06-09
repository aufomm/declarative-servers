resource "vault_policy" "secrets_readonly" {
  name   = "secrets_readonly_policy"
  policy = data.vault_policy_document.secrets_readonly.hcl
}

data "vault_policy_document" "secrets_readonly" {
  rule {
    path         = "${vault_mount.secrets.path}/data/*"
    capabilities = ["read"]
    description  = "Allow reading secret contents at all paths under this mount"
  }

  rule {
    path         = "${vault_mount.secrets.path}/metadata/*"
    capabilities = ["read", "list"]
    description  = "Allow listing available secrets and viewing their metadata"
  }
}

resource "vault_policy" "insomnia_readonly" {
  name   = "insomnia_readonly_policy"
  policy = data.vault_policy_document.insomnia_readonly.hcl
}

data "vault_policy_document" "insomnia_readonly" {
  rule {
    path         = "${vault_mount.insomnia.path}/data/*"
    capabilities = ["read"]
    description  = "Allow reading secret contents at all paths under the mount insomnia"
  }

  rule {
    path         = "${vault_mount.insomnia.path}/metadata/*"
    capabilities = ["read", "list"]
    description  = "Allow listing available secrets and viewing their metadata under the mount insomnia"
  }
}

# Admin policy document for Vault
data "vault_policy_document" "admin" {
  # Root level access
  rule {
    path         = "/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Full root level access for all operations"
  }

  # System health and initialization
  rule {
    path         = "sys/health"
    capabilities = ["read", "sudo"]
    description  = "Access to check system health status"
  }

  rule {
    path         = "sys/init"
    capabilities = ["read", "update"]
    description  = "Ability to read initialization status and initialize Vault"
  }

  # Auth methods management
  rule {
    path         = "auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Full access to manage authentication methods"
  }

  # Secret engines management
  rule {
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Full access to manage secret engine mounts"
  }

  # Policy management
  rule {
    path         = "sys/policies/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Full access to manage Vault policies"
  }

  # Token management
  rule {
    path         = "auth/token/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Full access to manage authentication tokens"
  }

  # Wildcard path management
  rule {
    path         = "+/+"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Full access to all wildcard paths"
  }

  # Secrets access
  rule {
    path         = "secret/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Full access to all secrets"
  }

  # System configuration
  rule {
    path         = "sys/configuration/*"
    capabilities = ["read", "update", "delete", "sudo"]
    description  = "Access to manage system configuration"
  }

  # Audit devices
  rule {
    path         = "sys/audit*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Full access to manage audit devices"
  }

  # Metrics access
  rule {
    path         = "sys/metrics"
    capabilities = ["read"]
    description  = "Read-only access to system metrics"
  }

  # Tools access
  rule {
    path         = "sys/tools/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Access to Vault tools without sudo capability"
  }

  # Lease management
  rule {
    path         = "sys/leases/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Full access to manage leases"
  }
}

# Create the admin policy
resource "vault_policy" "admin" {
  name   = "admin"
  policy = data.vault_policy_document.admin.hcl
}
