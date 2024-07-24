#!/bin/bash

# Validate the service is up and running
RESPONSE=$(curl -s --head --request GET http://localhost:8080)
HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP/" | awk '{print $2}')

if [ "$HTTP_STATUS" == "200" ]; then
  echo "Service is running successfully."
else
  echo "Service is not running. HTTP status code: $HTTP_STATUS"
  echo "Full response:"
  echo "$RESPONSE"
  exit 1
fi
