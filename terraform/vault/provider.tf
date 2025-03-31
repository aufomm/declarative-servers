terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.7.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.2.0"
    }
  }

  backend "s3" {
    bucket                      = "lab"
    key                         = "vault"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    region                      = "us-east-1"
  }
}
