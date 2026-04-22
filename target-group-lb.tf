resource "aws_lb_target_group" "wp_tg" {
  name     = "wordpress-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.wordpress_vpc.id
  health_check {
    path    = "/"
    matcher = "200-399"
  }
}