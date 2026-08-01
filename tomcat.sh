#!/bin/bash

# Update packages
sudo dnf update -y

# Install Java 21
sudo dnf install java-21-amazon-corretto -y

# Verify Java installation
java -version

# Download Tomcat 11.0.24
wget https://downloads.apache.org/tomcat/tomcat-11/v11.0.24/bin/apache-tomcat-11.0.24.tar.gz

# Extract Tomcat
tar -xzf apache-tomcat-11.0.24.tar.gz

# Configure Tomcat users
cat > apache-tomcat-11.0.24/conf/tomcat-users.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">

    <role rolename="manager-gui"/>
    <role rolename="manager-script"/>
    <role rolename="admin-gui"/>

    <user username="tomcat"
          password="root123456"
          roles="manager-gui,manager-script,admin-gui"/>

</tomcat-users>
EOF

# Allow remote access to Manager application
cat > apache-tomcat-11.0.24/webapps/manager/META-INF/context.xml <<EOF
<Context antiResourceLocking="false" privileged="true">
</Context>
EOF

# Make scripts executable
chmod +x apache-tomcat-11.0.24/bin/*.sh

# Start Tomcat
sh apache-tomcat-11.0.24/bin/startup.sh

echo "========================================"
echo "Tomcat started successfully."
echo "Open: http://<EC2-PUBLIC-IP>:8080"
echo "Manager: http://<EC2-PUBLIC-IP>:8080/manager/html"
echo "Username: tomcat"
echo "Password: root123456"
echo "========================================"
