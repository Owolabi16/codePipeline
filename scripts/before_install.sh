#!/bin/bash

# Navigate to the deployment archive directory
cd /opt/codedeploy-agent/deployment-root/*/d-*/deployment-archive

# Verify the contents of the unzipped directory
ls -l /opt/codedeploy-agent/deployment-root/*/d-*/deployment-archive
echo "new build"

