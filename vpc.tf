moved {
  from = aws_vpc.capstone_vpc
  to   = aws_vpc.wordpress_vpc
}

resource "aws_vpc" "wordpress_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "wordpress-vpc" }
}