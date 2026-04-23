# Elastic IP für NAT Gateway
resource "aws_eip" "nat_eip" {
  # vpc = true supprimé car non supporté
  tags = {
    Name = "nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "NATGateway"
  }
}