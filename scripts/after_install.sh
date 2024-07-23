#!/bin/bash

# Set permissions for application files
echo "Setting permissions for application files..."
./scripts/set_permissions.sh

# Move or prepare application files
echo "Preparing application files..."
./scripts/prepare_application.sh

# Install necessary dependencies
echo "Installing dependencies..."
./scripts/install_dependencies.sh

# Ensure Tomcat is installed and configured correctly
echo "Installing and configuring Tomcat..."
./scripts/install_tomcat.sh

# Confirming completion of the after_install phase
echo "After install script executed successfully."
