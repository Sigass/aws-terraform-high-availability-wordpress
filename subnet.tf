resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-wordpress-a" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-wordpress-b" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}a"
  tags              = { Name = "private-subnet-wordpress-a" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "${var.region}b"
  tags              = { Name = "private-subnet-wordpress-b" }
}
