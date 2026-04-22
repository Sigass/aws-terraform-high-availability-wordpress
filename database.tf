# Define the managed MySQL database layer.
resource "aws_db_subnet_group" "db_subs" {
  name = "db-subnets"
  # RDS requires subnets in at least two Availability Zones for validation,
  # even if Multi-AZ is disabled.
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  db_name                = "wordpressdb"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subs.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
}