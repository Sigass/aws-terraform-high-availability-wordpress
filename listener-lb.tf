resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.capstone_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.capstone_tg.arn
  }
}