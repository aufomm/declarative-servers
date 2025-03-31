variable "minio_region" {
  description = "Default MINIO region"
  default     = "us-east-1"
}

variable "minio_server" {
  description = "Default MINIO host and port"
  type        = string
  default     = "minio.li.lab"
}

variable "minio_user" {
  description = "MINIO user"
  default     = "fomm"
}

variable "minio_password" {
  description = "MINIO secret user"
}
