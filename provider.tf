# Configure Terraform and the AWS provider.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  # Décommentez et adaptez la ligne suivante si vous utilisez un profil spécifique
  # profile = "votre_profil"
}