terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.2.3"
    }
  }

  backend "s3" {
    bucket                      = "lab"
    key                         = "minio"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    region                      = "us-east-1"
  }
}

provider "minio" {
  minio_server   = var.minio_server
  minio_region   = var.minio_region
  minio_user     = var.minio_user
  minio_password = var.minio_password
  minio_ssl      = true
}
