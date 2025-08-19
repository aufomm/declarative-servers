terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.1.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.2.0"
    }
  }

  backend "s3" {
    bucket                      = "lab"
    key                         = "keycloak"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    region                      = "us-east-1"
  }
}

provider "keycloak" {
  url = "https://auth.li.lab:9443"
}

data "sops_file" "secrets" {
  source_file = "secrets-enc.yaml"
  input_type  = "yaml"
}