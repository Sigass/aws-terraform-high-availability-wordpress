#This handles the Load Balancer, the Launch Template (with the install script), and the Auto Scaling.

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_lb" "wp_alb" {
  name               = "wp-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  # ALB requires 2 subnets in different AZs
  subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

resource "aws_lb_target_group" "wp_tg" {
  name     = "wp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.capstone_vpc.id
  health_check {
    path    = "/"
    matcher = "200-399"
  }
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
  name_prefix            = "wp-lt-"
  image_id               = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y httpd php php-mysqlnd wget tar
    systemctl enable --now httpd
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
    find /var/www/html -type d -exec chmod 755 {} \;
    find /var/www/html -type f -exec chmod 644 {} \;
    systemctl restart httpd
  EOF
  )
}

resource "aws_autoscaling_group" "wp_asg" {
  vpc_zone_identifier       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.wp_tg.arn]

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  launch_template {
    id      = aws_launch_template.wp_lt.id
    version = "$Latest"
  }
}