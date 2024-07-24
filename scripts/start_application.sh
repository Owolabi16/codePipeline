# #!/bin/bash

# # Start Tomcat
# echo "Starting Tomcat service..."
# sudo systemctl start tomcat

# # Wait for a few seconds to give Tomcat some time to start
# sleep 5

# # Check if Tomcat started successfully
# if sudo systemctl is-active --quiet tomcat; then
#   echo "Tomcat started successfully."
# else
#   echo "Failed to start Tomcat. Checking status for more information..."
#   sudo systemctl status tomcat
#   exit 1
# fi
