terraform {
  backend "s3" {
    bucket         = "wordpress-terraform-state-2026" # Le nom de ton bucket S3 créé à l'étape 1
    key            = "dev/terraform.tfstate"      # Chemin du fichier dans le bucket
    region         = "us-west-2"                  # Ta région
    dynamodb_table = "terraform-lock"             # Le nom de ta table DynamoDB créée à l'étape 2
    encrypt        = true                         # Chiffrement du fichier au repos
  }
}