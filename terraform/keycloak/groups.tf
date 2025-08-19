resource "keycloak_group" "grafana_admins" {
  realm_id = keycloak_realm.terraform.id
  name     = "grafana_admins"
}

resource "keycloak_group_roles" "grafana_admins_roles" {
  realm_id = keycloak_realm.terraform.id
  group_id = keycloak_group.grafana_admins.id
  
  role_ids = [
    keycloak_role.grafanaadmin.id,
    data.keycloak_role.offline_access.id
  ]
}

resource "keycloak_group_memberships" "grafana_admins_group_members" {
  realm_id = keycloak_realm.terraform.id
  group_id = keycloak_group.grafana_admins.id

  members  = [
    keycloak_user.grafana-admin.username,
    keycloak_user.fomm.username
  ]
}

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

resource "keycloak_openid_client_scope" "groups_scope" {
  realm_id    = keycloak_realm.terraform.id
  name        = "groups"
  description = "Groups scope for accessing user group memberships"

  consent_screen_text = "Group memberships"
  include_in_token_scope = true
}

resource "keycloak_openid_group_membership_protocol_mapper" "groups_scope_mapper" {
  realm_id       = keycloak_realm.terraform.id
  client_scope_id = keycloak_openid_client_scope.groups_scope.id
  name      = "groups-mapper"
  claim_name = "groups"
  full_path  = false
  add_to_id_token     = true
  add_to_access_token = false
  add_to_userinfo     = false
}

resource "keycloak_openid_client_optional_scopes" "argocd_groups_optional_scope" {
  realm_id  = keycloak_realm.terraform.id
  client_id = keycloak_openid_client.argocd.id
  
  optional_scopes = [
    keycloak_openid_client_scope.groups_scope.name,
  ]
}