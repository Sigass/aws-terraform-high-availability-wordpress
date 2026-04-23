# Application Load Balancer
resource "aws_lb" "capstone_lb" {
  name               = "capstone-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false
  tags = {
    Name = "CapstoneLoadBalancer"
  }
}

resource "aws_lb_target_group" "capstone_tg" {
  name        = "capstone-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.wordpress_vpc.id
  target_type = "instance"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
