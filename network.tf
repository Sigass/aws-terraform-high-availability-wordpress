#set up VPC and Subnets using specific IP ranges.
resource "aws_vpc" "capstone_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "capstone-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.capstone_vpc.id
  tags   = { Name = "capstone-igw" }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.capstone_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}a"
  tags              = { Name = "private-subnet" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.capstone_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "pub_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}