resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.wordpress_vpc.id
  tags   = { Name = "wordpress-igw" }
}