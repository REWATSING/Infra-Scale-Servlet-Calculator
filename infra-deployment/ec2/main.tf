# Bastion Host Instance (Public Subnet)
resource "aws_instance" "bastion_host" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.public_subnet_id
  vpc_security_group_ids =  [var.bastion_sg_id]  
  associate_public_ip_address = true
  key_name = var.key_name
  tags = {
    Name = "Bastion Host"
  }
}


# Create a single Launch Template for both Blue & Green
resource "aws_launch_template" "app_launch_template" {
  name          = "app-launch-template"
  image_id      = var.ami_id  # Use the same golden AMI
  instance_type = var.instance_type  
  key_name      = var.key_name
  iam_instance_profile {
    name = var.instance_profile_name  # Ensure this is created in IAM-S3 module
  }
  monitoring {
    enabled = true  # Enables detailed monitoring (1-minute interval)
  }

  user_data = base64encode(<<EOF
#!/bin/bash -ex

# Remove existing ROOT application
rm -rf /var/lib/tomcat9/webapps/ROOT*

# Download and deploy new WAR file as ROOT from s3

aws s3 cp s3://calculator-bucket-271271271271/java-servlet-calculator.war /var/lib/tomcat9/webapps/ROOT.war

# Restart Tomcat
systemctl restart tomcat9
EOF
  )

  network_interfaces {
    associate_public_ip_address = false  # Private instances
    security_groups             = [var.private_sg_id]
  }
}