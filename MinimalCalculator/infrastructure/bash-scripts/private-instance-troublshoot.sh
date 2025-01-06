#!/bin/bash

# Function to check Maven version
check_maven_version() {
    echo "Checking Maven version..."
    mvn -v
    if [ $? -ne 0 ]; then
        echo "Maven is not installed or not properly configured."
    else
        echo "Maven is installed successfully."
    fi
}

# Function to check Java version
check_java_version() {
    echo "Checking Java version..."
    java -version
    if [ $? -ne 0 ]; then
        echo "Java is not installed or not properly configured."
    else
        echo "Java is installed successfully."
    fi
}

# Function to check Tomcat version
check_tomcat_version() {
    echo "Checking Tomcat version..."
    if systemctl is-active --quiet tomcat9.service; then
        echo "Tomcat is running."
        tomcat_version=$(catalina.sh version | grep "Server version" | cut -d' ' -f3-)
        echo "Tomcat Version: $tomcat_version"
    else
        echo "Tomcat is not running. Checking logs for errors..."
        journalctl -u tomcat9.service --since "5 minutes ago" | tail -n 20
    fi
}

# Function to check Nginx version
check_nginx_version() {
    echo "Checking Nginx version..."
    nginx -v
    if [ $? -ne 0 ]; then
        echo "Nginx is not installed or not properly configured."
    else
        echo "Nginx is installed successfully."
    fi
}

# Troubleshooting Tomcat
troubleshoot_tomcat() {
    echo "Troubleshooting Tomcat..."
    echo "Checking JAVA_HOME environment variable for Tomcat..."
    echo "JAVA_HOME: $JAVA_HOME"
    
    if [ -z "$JAVA_HOME" ]; then
        echo "JAVA_HOME is not set. Setting JAVA_HOME for Tomcat..."
        sudo sed -i 's|^#JAVA_HOME=.*|JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64|' /etc/default/tomcat9
    else
        echo "JAVA_HOME is already set to $JAVA_HOME"
    fi

    echo "Verifying Tomcat service status..."
    systemctl status tomcat9.service

    echo "Checking if Tomcat logs show any errors..."
    tail -n 50 /var/log/tomcat9/catalina.out
}

# Main script to run the checks
check_maven_version
check_java_version
check_tomcat_version
check_nginx_version
troubleshoot_tomcat

echo "Version checks and troubleshooting completed."

