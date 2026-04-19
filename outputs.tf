output "website_url" {
  description = "Access your WordPress site here"
  value       = "http://${aws_lb.wp_alb.dns_name}"
}