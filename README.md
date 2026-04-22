# AWS High-Availability Infrastructure for WordPress

## Project Overview

This Capstone project provisions a high-availability WordPress environment on AWS with Terraform. The site is intended to showcase Cameroon as "Africa in Miniature", highlighting its cultural and geographical diversity.

The infrastructure is designed to be scalable, fault-tolerant, and security-conscious, with WordPress served behind an Application Load Balancer and backed by Amazon RDS.

## Architecture Components

### 1. Networking

- Custom VPC: `192.168.0.0/26`
- Public subnet A: `192.168.0.0/28`
- Public subnet B: `192.168.0.16/28`
- Private subnet A: `192.168.0.32/28`
- Private subnet B: `192.168.0.48/28`
- Internet Gateway for public routing
- Public route table associated with both public subnets

This layout spans two Availability Zones in `us-west-2` and supports both ALB and RDS subnet requirements.

### 2. Compute and Traffic Distribution

- Application Load Balancer across two public subnets
- Target Group with HTTP health checks
- Auto Scaling Group with:
  - desired capacity: `1`
  - minimum size: `1`
  - maximum size: `2`
- Launch Template based on the latest Amazon Linux 2023 AMI retrieved through AWS SSM

The EC2 bootstrap installs Apache, PHP, and WordPress automatically through `user_data`.

### 3. Database

- Amazon RDS MySQL instance
- Dedicated DB subnet group across two private subnets
- Database access restricted to the WordPress application security group

### 4. Security

- Load balancer security group: allows HTTP `80` from the internet
- Web security group: allows HTTP `80` only from the load balancer security group
- Database security group: allows MySQL `3306` only from the web security group

## Automation Details

- Infrastructure as code with Terraform
- Split Terraform configuration by concern: VPC, subnets, route tables, security groups, load balancer, listener, target group, EC2 launch template, Auto Scaling, and database
- Dynamic AMI resolution via `aws_ssm_parameter`
- Output exposing the WordPress entry URL through the ALB DNS name

## HCP Terraform

This project is configured for HCP Terraform remote execution with:

- Organization: `sigass`
- Project: `aws`
- Workspace: `aws-terraform-high-availability-wordpress`

Before running Terraform remotely:

1. Run `terraform login` from your machine.
2. Create the HCP Terraform project `aws` in the `sigass` organization if needed.
3. Create the workspace `aws-terraform-high-availability-wordpress` in that project.
4. In the workspace, define:
   - Terraform variable: `db_password`
   - Environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN`
   - Region variable through environment variable: `AWS_DEFAULT_REGION=us-west-2`

For remote runs, `terraform plan` and `terraform apply` execute in HCP Terraform rather than entirely on the local machine.

## How to Deploy

1. Clone the repository:

```bash
git clone https://github.com/Sigass/aws-terraform-high-availability-wordpress.git
cd aws-terraform-high-availability-wordpress
```

2. Authenticate Terraform:

```bash
terraform login
terraform init
```

3. Review the execution plan:

```bash
terraform plan
```

4. Apply the infrastructure:

```bash
terraform apply
```

## Notes

- `db_password` should be treated as a sensitive value and managed in HCP Terraform rather than committed to source control.
- The current implementation uses HCP Terraform as the state and execution backend, not S3.
- The network is multi-AZ, even though the workload can scale from one to two application instances.
