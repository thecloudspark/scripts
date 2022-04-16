#!/bin/bash

# Fetch creds
source /actions-runner/.creds

# Stop the service
sudo /actions-runner/svc.sh stop

# Uninstall the service
sudo /actions-runner/svc.sh uninstall

# Remove configuration
./config.sh remove --token $GH_RUNNER_TOKEN

# Terminate instance
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
# aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION
