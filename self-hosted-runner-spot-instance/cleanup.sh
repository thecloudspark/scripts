#!/bin/bash

# Fetch creds
source /actions-runner/.creds

# Stop the service
sudo /actions-runner/svc.sh stop

# Uninstall the service
sudo /actions-runner/svc.sh uninstall

# Remove configuration
./config.sh remove --token $GH_RUNNER_TOKEN
