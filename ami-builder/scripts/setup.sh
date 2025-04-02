#!/bin/bash 

# Update system
sudo apt update -y

# Install Java 11 (default in Ubuntu 22.04)
sudo apt install -y openjdk-11-jdk ca-certificates

# Update system
sudo apt update -y

# Install required packages (Tomcat 9 is available in 22.04)
sudo apt install -y maven awscli tomcat9 tomcat9-admin tomcat9-common


# Verify Java installation
java -version || echo "Java installation failed!"
mvn -version || echo "Maven installation failed!"
aws --version || echo "AWS CLI installation failed!"

# Ensure Tomcat service starts
sudo systemctl start tomcat9
sudo systemctl enable tomcat9

# Set permissions for Tomcat deployment directory
sudo chown -R tomcat:tomcat /var/lib/tomcat9/webapps/
sudo chmod -R 775 /var/lib/tomcat9/webapps/

# Add 'ubuntu' user to 'tomcat' group for deployment access
sudo usermod -aG tomcat ubuntu

# Ensure Tomcat listens on IPv4 (0.0.0.0 instead of localhost)
sudo ss -tulnp | grep java 

# Download and deploy the latest WAR file from S3
sudo rm -rf /var/lib/tomcat9/webapps/ROOT*
aws sts get-caller-identity || { echo "AWS authentication failed!"; exit 1; }
aws s3 cp s3://calculator-bucket-271271271271/java-servlet-calculator.war /var/lib/tomcat9/webapps/ROOT.war

# Restart Tomcat to deploy the application
sudo systemctl restart tomcat9

# Verify Tomcat is running
systemctl status tomcat9 --no-page