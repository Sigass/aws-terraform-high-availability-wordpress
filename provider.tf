# Configure Terraform and the AWS provider.
terraform {
  cloud {
    organization = "sigass"

    workspaces {
      name = "aws-terraform-high-availability-wordpress"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}