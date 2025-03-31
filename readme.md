# Java Servlet Application with Blue-Green Deployment on AWS

## Overview
This project demonstrates the deployment of a Java Servlet-based calculator application using a robust CI/CD pipeline with blue-green deployment. The infrastructure is provisioned using Terraform, AMIs are built using Packer, and the deployment process is automated with GitHub Actions and AWS services.

## Architecture
The deployment follows a blue-green strategy with the following components:

- **Amazon EC2**: Hosts running Tomcat and serving the application.
- **Packer**: Used to create an Amazon Machine Image (AMI) with the pre-configured application environment.
- **Terraform**: Provisions infrastructure, including ALB, ASG, security groups, and networking.
- **Application Load Balancer (ALB)**: Distributes traffic between blue and green environments.
- **Auto Scaling Groups (ASG)**: Ensures high availability by managing EC2 instances.
- **S3**: Stores and retrieves the application `.war` file.
- **GitHub Actions**: Automates build and deployment workflows.
- **Tomcat**: Serves the Java Servlet application.
- **Health Checks**: Ensures seamless traffic shifting between environments.

## Deployment Workflow

### 1. Build AMI with Packer
- Packer is used to create an AMI with Tomcat pre-installed.
- The AMI is tagged for later deployment.

### 2. Infrastructure Provisioning with Terraform
- Terraform deploys:
  - VPC, subnets, and security groups.
  - ALB with HTTPS and forwarding rules.
  - ASGs for blue and green environments.
  - Launch templates with `user_data` scripts.

### 3. Application Deployment Process
- GitHub Actions workflow:
  - Builds the Java Servlet application using Maven.
  - Uploads the `.war` file to S3.
- EC2 instances fetch the `.war` file on startup via `user_data`:
  ```bash
  aws s3 cp s3://calculator-bucket/java-servlet-calculator.war /var/lib/tomcat9/webapps/
  systemctl restart tomcat9
  ```

### 4. Blue-Green Deployment
- ALB initially routes traffic to the `green` ASG.
- The `blue` ASG remains inactive or receives 0% traffic.
- After validation, traffic is shifted from `green` to `blue`.

## Terraform Code Highlights

### ALB Configuration
```hcl
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = 0  # Initially set to 0 for blue
      }

      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = 100  # All traffic to green initially
      }
    }
  }
}
```

### ASG Configuration
```hcl
resource "aws_autoscaling_group" "blue_asg" {
  name                = "blue-asg"
  desired_capacity    = 2
  min_size           = 1
  max_size           = 3
  launch_template {
    id      = var.aws_launch_template_id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.blue.arn]
}
```

## Health Check Endpoint
The application provides a `/health` endpoint that ALB uses to determine instance health.

## Accessing the Application
- The application is accessible via the ALB DNS name:
  ```
  https://first-alb-xxxxxxx.us-east-1.elb.amazonaws.com/
  ```

## Future Enhancements
- Implementing Canary Deployment.
- Adding Monitoring and Logging with CloudWatch.
- Automating rollback on deployment failure.

## Conclusion
This project demonstrates a production-grade Java application deployment with full automation, blue-green switching, and infrastructure-as-code practices. It ensures high availability, scalability, and seamless updates with zero downtime.

hello there