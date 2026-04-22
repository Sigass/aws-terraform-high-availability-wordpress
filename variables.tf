# Define reusable input variables for the infrastructure.
variable "region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/26"
}

variable "public_subnet_cidr" {
  type    = string
  default = "192.168.0.0/28"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "192.168.0.16/28"
}

variable "private_subnet_cidr" {
  type    = string
  default = "192.168.0.32/28"
}

variable "private_subnet_2_cidr" {
  type    = string
  default = "192.168.0.48/28"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "storage_bucket_name" {
  type        = string
  default     = null
  nullable    = true
  description = "Optional fixed S3 bucket name for WordPress media storage. Set this to keep the same bucket across runs and credential rotations in the same AWS account."
}

variable "db_backup_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain automated RDS backups."
}

variable "enable_wordpress_s3_iam_resources" {
  type        = bool
  default     = false
  description = "Create IAM role, policy, and instance profile for WordPress S3 uploads. Keep false in restricted lab accounts that deny IAM creation."
}

variable "enable_public_media_bucket_policy" {
  type        = bool
  default     = false
  description = "Attach a public-read bucket policy for media objects. Keep false when S3 Block Public Access prevents public bucket policies."
}