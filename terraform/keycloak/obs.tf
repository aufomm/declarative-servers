resource "keycloak_realm" "obs" {
  realm                 = "obs"
  enabled               = true
  registration_allowed  = false
  edit_username_allowed = false

  reset_password_allowed   = false
  remember_me              = true
  verify_email             = false
  login_with_email_allowed = true
  duplicate_emails_allowed = false
  
  revoke_refresh_token        = true
  default_signature_algorithm = "RS256"
}

resource "keycloak_realm_keystore_rsa_generated" "obs_keystore_rsa_generated" {
  name      = "obs-rsa-generated-key"
  realm_id  = keycloak_realm.obs.id
  enabled   = true
  active    = true
  priority  = 100
  algorithm = "RS256"
  key_size  = 2048
}

resource "keycloak_realm_keystore_ecdsa_generated" "obs_keystore_ecdsa_generated" {
  name               = "obs-ecdsa-generated"
  realm_id           = keycloak_realm.obs.id
  enabled            = true
  active             = true
  priority           = 101
  elliptic_curve_key = "P-256"
}

resource "keycloak_openid_client" "obs_k0s" {
  realm_id                     = keycloak_realm.obs.id
  client_id                    = "obs-k0s"
  name                         = "lab-k0s"
  description                  = "A client for k0s cluster to send telemetry data to obs server"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  service_accounts_enabled     = true
  client_secret                = data.sops_file.secrets.data["obs.k0s.client_secret"]
  standard_flow_enabled        = false
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
}

resource "keycloak_openid_audience_protocol_mapper" "k0s-collector-audience" {
  realm_id                 = keycloak_realm.obs.id
  client_id                = keycloak_openid_client.obs_k0s.id
  name                     = "k0s-collector-audience-mapper"
  included_custom_audience = "collector"
  add_to_access_token      = true
  add_to_id_token          = false
  depends_on               = [keycloak_openid_client.obs_k0s]
}

resource "keycloak_openid_client" "obs_lxc_docker" {
  realm_id                     = keycloak_realm.obs.id
  client_id                    = "obs-lxc-docker"
  name                         = "lab-lxc-docker"
  description                  = "A client for lxc-docker to send telemetry data to obs server"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  service_accounts_enabled     = true
  client_secret                = data.sops_file.secrets.data["obs.lxc-docker.client_secret"]
  standard_flow_enabled        = false
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
}

resource "keycloak_openid_audience_protocol_mapper" "lxc-collector-audience" {
  realm_id                 = keycloak_realm.obs.id
  client_id                = keycloak_openid_client.obs_lxc_docker.id
  name                     = "lxc-collector-audience-mapper"
  included_custom_audience = "collector"
  add_to_access_token      = true
  add_to_id_token          = false
  depends_on               = [keycloak_openid_client.obs_lxc_docker]
}

resource "keycloak_openid_client" "obs_rock" {
  realm_id                     = keycloak_realm.obs.id
  client_id                    = "obs-rock"
  name                         = "lab-rock"
  description                  = "A client for rock to send telemetry data to obs server"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  service_accounts_enabled     = true
  client_secret                = data.sops_file.secrets.data["obs.rock.client_secret"]
  standard_flow_enabled        = false
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
}

resource "keycloak_openid_audience_protocol_mapper" "rock-collector-audience" {
  realm_id                 = keycloak_realm.obs.id
  client_id                = keycloak_openid_client.obs_rock.id
  name                     = "rock-collector-audience-mapper"
  included_custom_audience = "collector"
  add_to_access_token      = true
  add_to_id_token          = false
  depends_on               = [keycloak_openid_client.obs_rock]
}
