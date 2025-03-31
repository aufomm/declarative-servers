resource "keycloak_realm" "terraform" {
  realm                 = "terraform"
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

resource "keycloak_realm_keystore_ecdsa_generated" "keystore_ecdsa_generated" {
  name     = "ecdsa-generated"
  realm_id = keycloak_realm.terraform.id

  enabled = true
  active  = true

  priority           = 100
  elliptic_curve_key = "P-256"
}