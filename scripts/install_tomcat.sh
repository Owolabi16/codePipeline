#!/bin/bash

set -e

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

# Fetch the JAVA_HOME path from update-java-alternatives
JAVA_HOME_PATH=$(sudo update-java-alternatives -l | awk '{print $3}')

# Check if JAVA_HOME_PATH is empty
if [ -z "$JAVA_HOME_PATH" ]; then
    echo "JAVA_HOME path could not be determined. Exiting."
    exit 1
fi

echo "JAVA_HOME is set to: $JAVA_HOME_PATH"

# Create Tomcat group and user
echo "Creating Tomcat user and group..."
sudo groupadd -f tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat || true

# Download and install Tomcat
echo "Downloading and installing Tomcat..."
cd /tmp
curl -O https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.0-M22/bin/apache-tomcat-11.0.0-M22.tar.gz

# Verify download
if [ ! -f apache-tomcat-11.0.0-M22.tar.gz ]; then
    echo "Tomcat download failed."
    exit 1
fi

sudo mkdir -p /opt/tomcat
sudo tar xzvf apache-tomcat-11.0.0-M22.tar.gz -C /opt/tomcat --strip-components=1

# Verify extraction
if [ ! -d /opt/tomcat/bin ]; then
    echo "Tomcat extraction failed."
    exit 1
fi

# Ensure the tomcat user has the correct permissions
echo "Setting ownership for Tomcat directory..."
sudo chown -R tomcat:tomcat /opt/tomcat

echo "Listing contents of /opt/tomcat/bin:"
sudo ls -la /opt/tomcat/bin

# Set permissions
echo "Setting permissions for Tomcat scripts..."
sudo chmod +x /opt/tomcat/bin/*.sh || true

# Verify permissions were set correctly
echo "Verifying permissions on Tomcat scripts..."
for script in /opt/tomcat/bin/*.sh; do
    if [ -f "$script" ]; then
        if ! sudo [ -x "$script" ]; then
            echo "Failed to set execute permission on $script"
            exit 1
        fi
    else
        echo "Script $script not found."
    fi
done

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
Environment="JAVA_HOME=$JAVA_HOME_PATH"
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
    sudo systemctl status tomcat
    sudo journalctl -xeu tomcat.service
    exit 1
fi
