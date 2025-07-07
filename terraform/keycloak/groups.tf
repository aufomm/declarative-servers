resource "keycloak_group" "argocd_admin_group" {
  realm_id       = keycloak_realm.terraform.id
  name     = "ArgoCDAdmins"
}

resource "keycloak_group_memberships" "argocd_admin_members" {
  realm_id       = keycloak_realm.terraform.id
  group_id = keycloak_group.argocd_admin_group.id

  members  = [
    keycloak_user.argocd-admin.username,
    keycloak_user.fomm.username
  ]
}

# Create a client scope for groups
resource "keycloak_openid_client_scope" "groups_scope" {
  realm_id    = keycloak_realm.terraform.id
  name        = "groups"
  description = "Groups scope for accessing user group memberships"
  
  consent_screen_text = "Group memberships"
  include_in_token_scope = true
}

# Create protocol mapper for the groups scope
resource "keycloak_openid_group_membership_protocol_mapper" "groups_scope_mapper" {
  realm_id       = keycloak_realm.terraform.id
  client_scope_id = keycloak_openid_client_scope.groups_scope.id
  name      = "groups-mapper"

  claim_name = "groups"
  full_path  = false
}

# Make the groups scope available as an optional scope for the client
resource "keycloak_openid_client_optional_scopes" "argocd_groups_optional_scope" {
  realm_id  = keycloak_realm.terraform.id
  client_id = keycloak_openid_client.argocd.id
  
  optional_scopes = [
    keycloak_openid_client_scope.groups_scope.name,
  ]
}
