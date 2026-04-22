resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.capstone_vpc.id
  tags   = { Name = "wordpress-igw" }
}
