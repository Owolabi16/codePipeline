#!/bin/bash

# Start Tomcat
sudo systemctl start tomcat

# Check if Tomcat started successfully
if sudo systemctl is-active --quiet tomcat; then
  echo "Tomcat started successfully."
else
  echo "Failed to start Tomcat."
  exit 1
fi