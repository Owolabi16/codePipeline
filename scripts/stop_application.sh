#!/bin/bash

# Stop Tomcat or other application servers
sudo systemctl stop tomcat

# Check if Tomcat stopped successfully
if ! sudo systemctl is-active --quiet tomcat; then
  echo "Tomcat stopped successfully."
else
  echo "Failed to stop Tomcat."
  exit 1
fi