moved {
  from = aws_vpc.capstone_vpc
  to   = aws_vpc.wordpress_vpc
}

resource "aws_vpc" "wordpress_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "wordpress-vpc" }
}