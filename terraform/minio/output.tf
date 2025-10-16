# 5. Output credentials
output "admin_access_key" {
  value = minio_iam_service_account.kong_backup_admin.access_key
  sensitive = true
}

output "admin_secret_key" {
  value = minio_iam_service_account.kong_backup_admin.secret_key
  sensitive = true
}

output "readonly_access_key" {
  value = minio_iam_service_account.kong_backup_readonly.access_key
  sensitive = true
}

output "readonly_secret_key" {
  value = minio_iam_service_account.kong_backup_readonly.secret_key
  sensitive = true
}

output "minio_bucket_id" {
  value = minio_s3_bucket.kong_backup.id
}

output "minio_bucket_url" {
  value = minio_s3_bucket.kong_backup.bucket_domain_name
}
