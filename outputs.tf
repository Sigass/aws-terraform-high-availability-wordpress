output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.capstone_lb.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.wordpress_db.endpoint
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host (if created)"
  value       = try(aws_instance.bastion.public_ip, null)
}