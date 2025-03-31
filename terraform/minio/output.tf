# 5. Output credentials
output "admin_access_key" {
  value = minio_iam_user.kong_admin_user.id
  # sensitive = true
}

output "admin_secret_key" {
  value     = minio_iam_user.kong_admin_user.secret
  sensitive = true
}

output "readonly_access_key" {
  value = minio_iam_user.kong_readonly_user.id
  # sensitive = true
}

output "readonly_secret_key" {
  value     = minio_iam_user.kong_readonly_user.secret
  sensitive = true
}

output "minio_bucket_id" {
  value = minio_s3_bucket.kong_backup.id
}

output "minio_bucket_url" {
  value = minio_s3_bucket.kong_backup.bucket_domain_name
}
