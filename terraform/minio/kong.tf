resource "minio_s3_bucket" "kong_backup" {
  bucket = "kong-backup"
}

resource "minio_iam_user" "kong_admin_user" {
  name = "kong-backup-admin"
}

resource "minio_iam_user" "kong_readonly_user" {
  name = "kong-backup-readonly"
}

resource "minio_iam_policy" "kong_admin_policy" {
  name = "kong-backup-admin-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:*"],
        Resource = [
          "arn:aws:s3:::kong-backup",
          "arn:aws:s3:::kong-backup/*"
        ]
      }
    ]
  })
}

# Read-only policy
resource "minio_iam_policy" "kong_readonly_policy" {
  name = "kong-backup-readonly-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::kong-backup",
          "arn:aws:s3:::kong-backup/*"
        ]
      }
    ]
  })
}

# Attach admin policy
resource "minio_iam_user_policy_attachment" "kong_admin_attachment" {
  user_name   = minio_iam_user.kong_admin_user.name
  policy_name = minio_iam_policy.kong_admin_policy.name
}

# Attach read-only policy
resource "minio_iam_user_policy_attachment" "kong_readonly_attachment" {
  user_name   = minio_iam_user.kong_readonly_user.name
  policy_name = minio_iam_policy.kong_readonly_policy.name
}
