#!/bin/bash -e

# Update and fix package issues
sudo apt update
sudo apt upgrade -y
sudo apt install -f -y || { echo "Fixing broken dependencies failed!"; exit 1; }
sudo apt clean && sudo apt autoremove -y

# Ensure ca-certificates for AWS CLI
sudo apt install -y ca-certificates

# Install required packages (using only OpenJDK 11)
if ! sudo apt install -y openjdk-11-jdk maven awscli tomcat9 tomcat9-admin tomcat9-common; then
    sudo apt install -f -y || { echo "Failed to install some dependencies!"; exit 1; }
fi

# Set default Java version
if command -v java >/dev/null 2>&1; then
    sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java || { echo "Failed to set Java version!"; exit 1; }
else
    echo "Java installation failed! Exiting."
    exit 1
fi

# Verify installations
java -version || { echo "Java installation failed!"; exit 1; }
mvn -version || { echo "Maven installation failed!"; exit 1; }
aws --version || { echo "AWS CLI installation failed!"; exit 1; }

# Start and enable Tomcat
sudo systemctl start tomcat9 || { echo "Failed to start Tomcat!"; exit 1; }
sudo systemctl enable tomcat9

# Set permissions for Tomcat deployment
sudo chown -R tomcat:tomcat /var/lib/tomcat9/webapps/
sudo chmod -R 775 /var/lib/tomcat9/webapps/
sudo usermod -aG tomcat ubuntu

# Modify Tomcat to listen on all IPs (only if file exists)
if [ -f /etc/tomcat9/server.xml ]; then
    sudo sed -i 's/address="127.0.0.1"/address="0.0.0.0"/' /etc/tomcat9/server.xml
else
    echo "Warning: Tomcat server.xml not found!"
fi

# Deploy WAR file from S3
sudo rm -rf /var/lib/tomcat9/webapps/ROOT*
if ! aws s3 cp s3://calculator-bucket-271271271271/java-servlet-calculator.war /var/lib/tomcat9/webapps/ROOT.war; then
    echo "WAR file deployment failed! Checking bucket permissions..."
    aws s3 ls s3://calculator-bucket-271271271271/ || echo "Bucket access denied!"
    exit 1
fi

# Set WAR file permissions
sudo chown tomcat:tomcat /var/lib/tomcat9/webapps/ROOT.war
sudo chmod 644 /var/lib/tomcat9/webapps/ROOT.war

# Restart Tomcat
sudo systemctl restart tomcat9 || { echo "Failed to restart Tomcat!"; exit 1; }

# Verify Tomcat is running
systemctl status tomcat9 --no-pager
