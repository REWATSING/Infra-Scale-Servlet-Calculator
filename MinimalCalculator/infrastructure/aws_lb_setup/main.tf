# aws_lb_setup/main.tf

provider "aws" {
  region = var.region
}

# Create a new security group for the ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security Group"
  }
}

# Create the Application Load Balancer
resource "aws_lb" "main" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id] # Use new ALB security group
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "my-alb"
  }
}

# Create the Target Group
resource "aws_lb_target_group" "main" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "my-target-group"
  }
}

# Create the HTTP listener for the ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Attach EC2 instances to the target group
resource "aws_lb_target_group_attachment" "instance_attachment" {
  count            = length(var.ec2_instance_ids)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = element(var.ec2_instance_ids, count.index)
  port             = 80
}

# Allow inbound traffic from the ALB security group to private instances
resource "aws_security_group_rule" "allow_alb_to_instances" {
  security_group_id        = var.existing_sg_id # Use existing security group for private instances
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}
