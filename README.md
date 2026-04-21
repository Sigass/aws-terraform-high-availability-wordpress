# aws-terraform-high-availability-wordpress
Automated Multi-AZ WordPress infrastructure on AWS using Terraform, featuring ALB, Auto Scaling, and RDS.

## Terraform Cloud

This project is configured to use Terraform Cloud with:

- Organization: `aws`
- Workspace: `aws`
- Execution mode: remote

Before running Terraform, complete these steps:

1. Log in from your CLI with `terraform login`.
2. Create the Terraform Cloud workspace `aws` in the `aws` organization if it does not already exist.
3. In Terraform Cloud, add these workspace variables:
   - Terraform variable: `db_password`
   - Environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN`
4. Move any sensitive values out of local `terraform.tfvars` if you want Terraform Cloud to be the source of truth for runs.

For remote runs, `terraform plan` and `terraform apply` will execute in Terraform Cloud rather than on your machine.
