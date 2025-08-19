data "keycloak_role" "offline_access" {
  realm_id = keycloak_realm.terraform.id
  name     = "offline_access"
}

resource "keycloak_role" "grafanaadmin" {
  realm_id  = keycloak_realm.terraform.id
  client_id = keycloak_openid_client.grafana.id
  name      = "grafanaadmin"
}

resource "keycloak_openid_user_client_role_protocol_mapper" "grafana_roles_claim" {
  realm_id            = keycloak_realm.terraform.id
  client_id           = keycloak_openid_client.grafana.id
  name                = "client roles"
  claim_name          = "roles"
  add_to_id_token     = true
  add_to_access_token = false
  add_to_userinfo     = false
  multivalued         = true
}