output "website_url" {
  description = "Access your WordPress site here"
  value       = "http://${aws_lb.wp_alb.dns_name}"
}

output "storage_bucket_name" {
  description = "S3 bucket name for WordPress storage"
  value       = aws_s3_bucket.wordpress_storage.bucket
}