#!/bin/bash

# Updating package list and installing dependencies
echo "Updating package list and installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y default-jdk

# Creating Tomcat user and group
echo "Creating Tomcat user and group..."
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

# Downloading and installing Tomcat
echo "Downloading and installing Tomcat..."
wget https://downloads.apache.org/tomcat/tomcat-11/v11.0.0-M22/bin/apache-tomcat-11.0.0-M22.tar.gz
sudo tar -xzvf apache-tomcat-11.0.0-M22.tar.gz -C /opt/tomcat --strip-components=1

# Setting permissions
echo "Setting permissions for Tomcat..."
sudo chown -RH tomcat: /opt/tomcat
sudo sh -c 'chmod +x /opt/tomcat/bin/*.sh'

# Configuring JAVA_HOME
JAVA_HOME_PATH=$(update-java-alternatives -l | awk '{print $3}')

# Creating Tomcat systemd service file
echo "Creating Tomcat systemd service file..."
sudo tee /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=$JAVA_HOME_PATH"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
SuccessExitStatus=143
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reloading systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enabling Tomcat service
echo "Enabling Tomcat service..."
sudo systemctl enable tomcat

# Check if Tomcat service is enabled
if systemctl is-enabled tomcat; then
    echo "Tomcat service enabled successfully."
else
    echo "Failed to enable Tomcat service."
    exit 1
fi
