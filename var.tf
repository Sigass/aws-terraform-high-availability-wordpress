variable "enable_public_media_bucket_policy" {
  description = "Activer la policy publique pour le bucket S3 media."
  type        = bool
  default     = false
}

variable "enable_wordpress_s3_iam_resources" {
  description = "Activer les ressources IAM pour l'accès S3 de WordPress."
  type        = bool
  default     = false
}
variable "region" {
  type    = string
  default = "us-west-2"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
  type    = string
  default = "10.0.4.0/24"
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
  description = "Nom du bucket S3 pour WordPress"
  type        = string
  default     = "wordpress-media-bucket"
}
