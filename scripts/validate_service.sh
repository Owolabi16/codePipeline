#!/bin/bash

Validate the service is up and running
if curl -s --head  --request GET http://localhost:8080 | grep "200 OK" > /dev/null; then
  echo "Service is running successfully."
else
  echo "Service is not running."
  exit 1
fi