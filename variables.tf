#defines the "placeholders" for configuration, allowing to reuse the code easily.
variable "region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/27"
}

variable "public_subnet_cidr" {
  type    = string
  default = "192.168.0.0/28"
}

variable "private_subnet_cidr" {
  type    = string
  default = "192.168.0.16/28"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}