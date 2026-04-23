# Private Subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet1"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.private_subnet_2_cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet2"
  }
}
