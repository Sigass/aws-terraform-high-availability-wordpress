# Launch Template

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_launch_template" "launch_template" {
  name                   = "wordpress-template"
  image_id               = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.wp_sg.id, aws_security_group.alb_sg.id]
  user_data              = base64encode(templatefile("userdata.sh", { rds_endpoint = replace(aws_db_instance.wordpress_db.endpoint, ":3306", "") }))
  key_name               = "vockey"
}

resource "aws_autoscaling_group" "autoscaling_group" {
  depends_on       = [aws_nat_gateway.nat]
  default_cooldown = 30
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  desired_capacity = 2
  min_size         = 2
  max_size         = 3
  target_group_arns   = [aws_lb_target_group.capstone_tg.arn]
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tag {
    key                 = "Name"
    value               = "AutoScale-Wordpress"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                      = "scale-out-policy"
  autoscaling_group_name    = aws_autoscaling_group.autoscaling_group.name
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 30
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}