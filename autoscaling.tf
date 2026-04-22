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