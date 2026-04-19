#This handles the Load Balancer, the Launch Template (with the install script), and the Auto Scaling.

resource "aws_lb" "wp_alb" {
  name               = "wp-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  # ALB requires 2 subnets in different AZs
  subnets            = [aws_subnet.public_1.id, aws_subnet.private_1.id]
}

resource "aws_lb_target_group" "wp_tg" {
  name     = "wp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.capstone_vpc.id
  health_check { path = "/" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wp_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp_tg.arn
  }
}

resource "aws_launch_template" "wp_lt" {
  name_prefix   = "wp-lt-"
  image_id      = "ami-0cf2b4e024cdb6960" # Amazon Linux 2023 us-west-2
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd mariadb105 php php-mysqlnd wget
    systemctl start httpd
    systemctl enable httpd
    cd /var/www/html
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* .
    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/wordpressdb/" wp-config.php
    sed -i "s/username_here/${var.db_username}/" wp-config.php
    sed -i "s/password_here/${var.db_password}/" wp-config.php
    sed -i "s/localhost/${aws_db_instance.wordpress_db.address}/" wp-config.php
    chown -R apache:apache /var/www/html
  EOF
  )
}

resource "aws_autoscaling_group" "wp_asg" {
  vpc_zone_identifier = [aws_subnet.public_1.id]
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.wp_tg.arn]
  launch_template {
    id      = aws_launch_template.wp_lt.id
    version = "$Latest"
  }
}