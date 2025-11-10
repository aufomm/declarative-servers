resource "keycloak_realm" "ai" {
  realm                 = "ai"
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

resource "keycloak_realm_keystore_rsa_generated" "ai_keystore_rsa_generated" {
  name      = "ai-rsa-generated-key"
  realm_id  = keycloak_realm.ai.id
  enabled   = true
  active    = true
  priority  = 100
  algorithm = "RS256"
  key_size  = 2048
}

resource "keycloak_realm_keystore_ecdsa_generated" "ai_keystore_ecdsa_generated" {
  name               = "ai-ecdsa-generated"
  realm_id           = keycloak_realm.ai.id
  enabled            = true
  active             = true
  priority           = 101
  elliptic_curve_key = "P-256"
}

resource "keycloak_openid_client" "mcp-private" {
  realm_id                     = keycloak_realm.ai.id
  client_id                    = "mcp-private"
  name                         = "lab-mcp-private"
  description                  = "A client for testing mcp oauth via kong for token introspection"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  service_accounts_enabled     = true
  client_secret                = data.sops_file.secrets.data["mcp.client_secret"]
  standard_flow_enabled        = false
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
}

resource "keycloak_openid_client" "mcp-weather" {
  realm_id    = keycloak_realm.ai.id
  client_id   = "mcp-weather"
  name        = "lab-mcp-weather"
  description = "A client for testing weather mcp oauth via kong"
  enabled     = true
  access_type = "PUBLIC"
  valid_redirect_uris = [
    "http://localhost:6274/oauth/callback/*",
    "https://app.insomnia.rest/oauth/redirect"
  ]
  web_origins = [
    "http://localhost:6274",
    "https://app.insomnia.rest"
  ]
  service_accounts_enabled     = false
  standard_flow_enabled        = true
  pkce_code_challenge_method   = "S256"
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
}

resource "keycloak_openid_audience_protocol_mapper" "weather_audience_mapper" {
  realm_id    = keycloak_realm.ai.id
  client_id                = keycloak_openid_client.mcp-weather.id
  name                     = "weather-audience-mapper"
  included_custom_audience = "http://localhost:8000/weather/mcp"
  add_to_access_token      = true
  add_to_id_token          = true
  depends_on               = [keycloak_openid_client.mcp-weather]
}


resource "keycloak_user" "mcp-client" {
  realm_id       = keycloak_realm.ai.id
  username       = "mcp-client"
  enabled        = true
  email_verified = true
  email          = "mcp-client@li.local"
  first_name     = "mcp"
  last_name      = "client"
  initial_password {
    value     = data.sops_file.secrets.data["users.mcp-client.password"]
    temporary = false
  }
}
