resource "minio_s3_bucket" "kong_backup" {
  bucket = "kong-backup"
}

resource "minio_iam_policy" "kong_backup_admin" {
  name = "kong-backup-admin-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource": "arn:aws:s3:::${minio_s3_bucket.kong_backup.bucket}"
      },
      {
        "Effect": "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        "Resource": "arn:aws:s3:::${minio_s3_bucket.kong_backup.bucket}/*"
      }
    ]
  })
}

# Read-only policy
resource "minio_iam_policy" "kong_backup_readonly" {
  name = "kong-backup-readonly-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource": "arn:aws:s3:::${minio_s3_bucket.kong_backup.bucket}"
      },
      {
        "Effect" : "Allow",
        "Action" : ["s3:GetObject"],
        "Resource": "arn:aws:s3:::${minio_s3_bucket.kong_backup.bucket}/*"
      }
    ]
  })
}

# Attach admin policy
resource "minio_iam_user_policy_attachment" "kong_backup_admin_attachment" {
  user_name   = minio_iam_user.kong_backup_admin.name
  policy_name = minio_iam_policy.kong_backup_admin.name
}

# Attach read-only policy
resource "minio_iam_user_policy_attachment" "kong_backup_readonly_attachment" {
  user_name   = minio_iam_user.kong_backup_readonly.name
  policy_name = minio_iam_policy.kong_backup_readonly.name
}

resource "minio_iam_user" "kong_backup_admin" {
  name = "kong-backup-admin"
}

resource "minio_iam_user" "kong_backup_readonly" {
  name = "kong-backup-readonly"
}

resource "minio_iam_service_account" "kong_backup_admin" {
  target_user = minio_iam_user.kong_backup_admin.name
}

resource "minio_iam_service_account" "kong_backup_readonly" {
  target_user = minio_iam_user.kong_backup_readonly.name
}