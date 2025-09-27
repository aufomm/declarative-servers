locals {
  readonly_policies = {
    secrets = {
      mount            = vault_mount.secrets.path
      additional_rules = []
      policy_name      = "secrets_readonly_policy"
    }
    insomnia = {
      mount            = vault_mount.insomnia.path
      additional_rules = []
      policy_name      = "insomnia_readonly_policy"
    }
    konnect = {
      mount = vault_mount.konnect.path
      additional_rules = [
        {
          path         = "auth/token/create"
          capabilities = ["update"]
          description  = "Allow creation of child tokens (required by Terraform Vault provider)"
        }
      ]
      policy_name = "konnect_readonly"
    }
  }
}

resource "vault_policy" "readonly" {
  for_each = local.readonly_policies

  name   = each.value.policy_name
  policy = data.vault_policy_document.readonly[each.key].hcl
}

data "vault_policy_document" "readonly" {
  for_each = local.readonly_policies

  dynamic "rule" {
    for_each = [
      {
        path         = "${each.value.mount}/data/*"
        capabilities = ["read"]
        description  = "Allow reading secret contents at all paths under the mount ${each.key}"
      },
      {
        path         = "${each.value.mount}/metadata/*"
        capabilities = ["read", "list"]
        description  = "Allow listing available secrets and viewing their metadata under the mount ${each.key}"
      }
    ]
    content {
      path         = rule.value.path
      capabilities = rule.value.capabilities
      description  = rule.value.description
    }
  }

  dynamic "rule" {
    for_each = each.value.additional_rules
    content {
      path         = rule.value.path
      capabilities = rule.value.capabilities
      description  = rule.value.description
    }
  }
}

resource "vault_policy" "konnect_admin" {
  name   = "konnect_admin"
  policy = data.vault_policy_document.konnect_admin.hcl
}

data "vault_policy_document" "konnect_admin" {
  rule {
    path         = "${vault_mount.konnect.path}/data/*"
    capabilities = ["create", "update", "read", "delete"]
    description  = "Allow admin secret contents at all paths under the mount konnect"
  }
  rule {
    path         = "${vault_mount.konnect.path}/metadata/*"
    capabilities = ["create", "update", "read", "delete", "list"]
    description  = "Allow listing available secrets and viewing their metadata under the mount konnect"
  }
  rule {
    path         = "auth/token/create"
    capabilities = ["update"]
    description  = "Allow creation of child tokens (required by Terraform Vault provider)"
  }

  rule {
    path         = "${vault_mount.rsa.path}/issue/${vault_pki_secret_backend_role.rsa_client_cert.name}"
    capabilities = ["create", "update"]
    description  = "Allow issuing certificates using the client-cert role"
  }
  rule {
    path         = "sys/mounts/${vault_mount.rsa.path}"
    capabilities = ["read"]
    description  = "Allow reading mount metadata for rsa"
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

# Allow Konnect Admins to manage policies dynamically
resource "vault_policy" "konnect_policy_admin" {
  name   = "konnect_policy_admin"
  policy = data.vault_policy_document.konnect_policy_admin.hcl
}

data "vault_policy_document" "konnect_policy_admin" {
  rule {
    path         = "sys/policies/acl/*"
    capabilities = ["create", "update", "read", "delete", "list"]
    description  = "Allow managing Vault policies"
  }
}
