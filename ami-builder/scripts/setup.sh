#!/bin/bash -ex

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install Java 11 & 17
sudo apt install -y openjdk-11-jdk openjdk-17-jdk

# Install required packages
sudo apt install -y maven awscli tomcat9 tomcat9-admin tomcat9-common

# Set default Java to Java 11 (or change to 17 if needed)
sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java

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
sudo sed -i 's/address="127.0.0.1"/address="0.0.0.0"/' /etc/tomcat9/server.xml

# Download and deploy the latest WAR file from S3
sudo rm -rf /var/lib/tomcat9/webapps/ROOT*
aws s3 cp s3://calculator-bucket-271271271271/java-servlet-calculator.war /var/lib/tomcat9/webapps/ROOT.war

# Set proper permissions for the WAR file
sudo chown tomcat:tomcat /var/lib/tomcat9/webapps/ROOT.war
sudo chmod 644 /var/lib/tomcat9/webapps/ROOT.war

# Restart Tomcat to deploy the application
sudo systemctl restart tomcat9

# Verify Tomcat is running
systemctl status tomcat9 --no-pager