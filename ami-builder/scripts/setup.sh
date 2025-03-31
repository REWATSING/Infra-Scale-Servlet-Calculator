#!/bin/bash -ex

# Update and fix package issues
sudo apt update -y
sudo apt upgrade -y
sudo apt install -f -y || echo "Fixing broken dependencies failed!"
sudo apt clean && sudo apt autoremove -y

# Install required packages (retry if failed)
sudo apt install -y openjdk-11-jdk openjdk-17-jdk || sudo apt install -y openjdk-11-jdk
sudo apt install -y maven awscli tomcat9 tomcat9-admin tomcat9-common || sudo apt install -f -y

# Set default Java version
sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java

# Verify installations
java -version || echo "Java installation failed!"
mvn -version || echo "Maven installation failed!"
aws --version || echo "AWS CLI installation failed!"

# Start and enable Tomcat
sudo systemctl start tomcat9
sudo systemctl enable tomcat9

# Set permissions for Tomcat deployment
sudo chown -R tomcat:tomcat /var/lib/tomcat9/webapps/
sudo chmod -R 775 /var/lib/tomcat9/webapps/
sudo usermod -aG tomcat ubuntu

# Modify Tomcat to listen on all IPs
sudo sed -i 's/address="127.0.0.1"/address="0.0.0.0"/' /etc/tomcat9/server.xml

# Deploy WAR file
sudo rm -rf /var/lib/tomcat9/webapps/ROOT*
aws s3 cp s3://calculator-bucket-271271271271/java-servlet-calculator.war /var/lib/tomcat9/webapps/ROOT.war

# Set WAR file permissions
sudo chown tomcat:tomcat /var/lib/tomcat9/webapps/ROOT.war
sudo chmod 644 /var/lib/tomcat9/webapps/ROOT.war

# Restart Tomcat
sudo systemctl restart tomcat9

# Verify Tomcat is running
systemctl status tomcat9 --no-pager
