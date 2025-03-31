
# Create the Application Load Balancer
resource "aws_lb" "main" {
  name               = "first-alb"
  internal           = false
  security_groups    = [var.alb_sg_id]
  load_balancer_type = "application"
  subnets            = var.subnet_ids["public"]

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "First-ALB"
  }
}


# Create the Blue Target Group
resource "aws_lb_target_group" "blue" {
  name     = "blue-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/health"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP"
  }

  tags = {
    Name = "blue-target-group"
  }
}

# Create the Green Target Group
resource "aws_lb_target_group" "green" {
  name     = "green-target-group"
  port     = 8080 
  protocol = "HTTP" 
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/health" 
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP" # Ensure health check uses HTTPS as well
  }

  tags = {
    Name = "green-target-group"
  }
}


# HTTP Listener (Redirect to HTTPS)
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB HTTPS Listener with 50/50 traffic split
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.acm_certificate_arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = 100   # 100% traffic to Blue
      }

      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = 0   # 0% traffic to Green
      }

    }
  }
}




# Blue ASG
resource "aws_autoscaling_group" "blue_asg" {
  name                = "blue-asg"
  desired_capacity    = 2  # Start with 2 (1 per AZ)
  min_size           = 2
  max_size           = 3
  vpc_zone_identifier = var.private_subnet_ids  # Ensure instances launch in multiple AZs
  launch_template {
    id      = var.blue_launch_template_id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.blue.arn]

  tag {
    key                 = "Name"
    value               = "Blue"
    propagate_at_launch = true
  }

  # Align ASG health checks with ALB
  health_check_type          = "ELB"   # This makes the ASG use the ALB health check
  health_check_grace_period = 300      # This is the grace period after instance launch

}

# Green ASG
resource "aws_autoscaling_group" "green_asg" {
  name                = "green-asg"
  desired_capacity    = 2
  min_size           = 2
  max_size           = 3
  vpc_zone_identifier = var.private_subnet_ids  
  launch_template {
    id      = var.green_launch_template_id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.green.arn]

  tag {
    key                 = "Name"
    value               = "Green"
    propagate_at_launch = true
  }

  # Align ASG health checks with ALB
  health_check_type          = "ELB"   # This makes the ASG use the ALB health check
  health_check_grace_period = 300      # This is the grace period after instance launch

}




# CloudWatch Alarm for Scaling Up (Blue ASG)
resource "aws_cloudwatch_metric_alarm" "blue_scale_up" {
  alarm_name          = "blue-scale-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30  # Scale up if CPU ≥ 30%
  alarm_description   = "Scale up when CPU utilization is greater than or equal to 30%."
  alarm_actions       = [
    aws_autoscaling_policy.blue_scale_up.arn,
    aws_sns_topic.tomcat_server_alerts.arn
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.blue_asg.name
  }
}

# CloudWatch Alarm for Scaling Down (Blue ASG)
resource "aws_cloudwatch_metric_alarm" "blue_scale_down" {
  alarm_name          = "blue-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5  # Scale down if CPU ≤ 5%
  alarm_description   = "Scale down when CPU utilization is less than or equal to 5%."
  alarm_actions       = [
    aws_autoscaling_policy.blue_scale_down.arn,
    aws_sns_topic.tomcat_server_alerts.arn
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.blue_asg.name
  }
}

# Auto Scaling Policy for Scale-Up (Blue ASG)
resource "aws_autoscaling_policy" "blue_scale_up" {
  name                   = "blue-scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 60
  autoscaling_group_name = aws_autoscaling_group.blue_asg.name
}

# Auto Scaling Policy for Scale-Down (Blue ASG)
resource "aws_autoscaling_policy" "blue_scale_down" {
  name                   = "blue-scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 60
  autoscaling_group_name = aws_autoscaling_group.blue_asg.name
}



# CloudWatch Alarm for Scaling Up (Green ASG)
resource "aws_cloudwatch_metric_alarm" "green_scale_up" {
  alarm_name          = "green-scale-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30  # Scale up if CPU ≥ 30%
  alarm_description   = "Scale up when CPU utilization is greater than or equal to 30%."
  alarm_actions       = [
    aws_autoscaling_policy.green_scale_up.arn,
    aws_sns_topic.tomcat_server_alerts.arn
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.green_asg.name
  }
}

# CloudWatch Alarm for Scaling Down (Green ASG)
resource "aws_cloudwatch_metric_alarm" "green_scale_down" {
  alarm_name          = "green-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5  # Scale down if CPU ≤ 5%
  alarm_description   = "Scale down when CPU utilization is less than or equal to 5%."
  alarm_actions       = [
    aws_autoscaling_policy.green_scale_down.arn,
    aws_sns_topic.tomcat_server_alerts.arn
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.green_asg.name
  }
}

# Auto Scaling Policy for Scale-Up (Green ASG)
resource "aws_autoscaling_policy" "green_scale_up" {
  name                   = "green-scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 60
  autoscaling_group_name = aws_autoscaling_group.green_asg.name
}

# Auto Scaling Policy for Scale-Down (Green ASG)
resource "aws_autoscaling_policy" "green_scale_down" {
  name                   = "green-scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 60
  autoscaling_group_name = aws_autoscaling_group.green_asg.name
}


# Create an SNS Topic
resource "aws_sns_topic" "tomcat_server_alerts" {
  name = "tomcat-alerts-topic"
}

# Subscribe your email to the SNS Topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.tomcat_server_alerts.arn
  protocol  = "email"
  endpoint  = "rewatsingh271@gmail.com"
}


# Allow CloudWatch and Auto Scaling to publish to SNS
resource "aws_sns_topic_policy" "sns_policy" {
  arn    = aws_sns_topic.tomcat_server_alerts.arn
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudwatch.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.tomcat_server_alerts.arn}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "autoscaling.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.tomcat_server_alerts.arn}"
    }
  ]
}
POLICY
}

# Auto Scaling Notification for Blue ASG
resource "aws_autoscaling_notification" "blue_asg_notifications" {
  group_names = [aws_autoscaling_group.blue_asg.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = aws_sns_topic.tomcat_server_alerts.arn
}

# Auto Scaling Notification for Green ASG
resource "aws_autoscaling_notification" "green_asg_notifications" {
  group_names = [aws_autoscaling_group.green_asg.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = aws_sns_topic.tomcat_server_alerts.arn
}