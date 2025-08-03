# Create a group for Grafana users
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