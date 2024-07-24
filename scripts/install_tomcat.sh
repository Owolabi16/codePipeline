#!/bin/bash

# Update package list and install dependencies
echo "Updating package list and installing dependencies..."
sudo apt update -y

# Install Java
echo "Installing Java..."
wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
sudo apt install -y ./jdk-21_linux-x64_bin.deb
if ! java -version; then
    echo "Java installation failed."
    exit 1
fi

# Create Tomcat group and user
echo "Creating Tomcat user and group..."
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# Download and install Tomcat
echo "Downloading and installing Tomcat..."
cd /tmp
curl -O https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.0-M22/bin/apache-tomcat-11.0.0-M22.tar.gz
sudo mkdir -p /opt/tomcat
sudo tar xzvf apache-tomcat-11.0.0-M22.tar.gz -C /opt/tomcat --strip-components=1

# Set permissions
echo "Setting permissions for Tomcat..."
sudo chown -RH tomcat: /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh

# Set up Tomcat as a systemd service
echo "Creating Tomcat systemd service..."
sudo bash -c 'cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target
[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/jdk-21"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Start and enable Tomcat service
echo "Starting and enabling Tomcat service..."
sudo systemctl start tomcat
sudo systemctl enable tomcat

# Check if Tomcat is running
if sudo systemctl status tomcat | grep -q "active (running)"; then
    echo "Tomcat installed and running successfully."
else
    echo "Tomcat installation or startup failed."
    exit 1
fi
