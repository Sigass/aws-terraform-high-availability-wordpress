output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.capstone_lb.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.wordpress_db.endpoint
}

output "vpc_id" {
  description = "ID du VPC principal"
  value       = aws_vpc.wordpress_vpc.id
}

output "public_subnet_1_id" {
  description = "ID du subnet public 1"
  value       = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "ID du subnet public 2"
  value       = aws_subnet.public_subnet_2.id
}

output "private_subnet_1_id" {
  description = "ID du subnet privé 1"
  value       = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  description = "ID du subnet privé 2"
  value       = aws_subnet.private_subnet_2.id
}

output "alb_sg_id" {
  description = "ID du security group du load balancer"
  value       = aws_security_group.alb_sg.id
}

output "wp_sg_id" {
  description = "ID du security group WordPress"
  value       = aws_security_group.wp_sg.id
}

output "db_sg_id" {
  description = "ID du security group base de données"
  value       = aws_security_group.db_sg.id
}

output "nat_gateway_id" {
  description = "ID du NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "alb_target_group_arn" {
  description = "ARN du Target Group de l'ALB"
  value       = aws_lb_target_group.capstone_tg.arn
}