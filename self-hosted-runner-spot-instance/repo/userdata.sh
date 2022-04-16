#!/bin/bash

github_user="000000000000000000000000000000000000000000"
github_repo="000000000000000000000000000000000000000000"
access_token="ghp_000000000000000000000000000000000000000000"
runner_timeout=300

# Download jq and pip
yum install jq python-pip -y

# Create and move to the working directory
mkdir /actions-runner && cd /actions-runner

# Download the latest runner package
latest_version_label=$(curl -s -X GET 'https://api.github.com/repos/actions/runner/releases/latest' | jq -r '.tag_name')
latest_version=$(echo ${latest_version_label:1})
curl -o actions-runner-linux-x64-latest.tar.gz -L https://github.com/actions/runner/releases/download/$latest_version_label/actions-runner-linux-x64-$latest_version.tar.gz

# Extract the installer
tar xzf ./actions-runner-linux-x64-latest.tar.gz

# Change the owner of the directory to ec2-user
chown ec2-user -R /actions-runner

# Get the organization runner's token
token=$(curl -s -XPOST -H "authorization: token $access_token" https://api.github.com/repos/$github_user/$github_repo/actions/runners/registration-token | jq -r .token)

# Write details to file
echo -e "GH_HOSTNAME=$HOSTNAME\nGH_USERNAME=$github_user\nGH_REPO=$github_repo\nGH_RUNNER_TOKEN=$token\nGH_IDLE_TIMEOUT=$runner_timeout" > /actions-runner/.creds

# Create the runner and start the configuration experience
sudo -u ec2-user ./config.sh --url https://github.com/$github_user/$github_repo --token $token --name "spot-runner-$(hostname)" --unattended

# Create the runner's service
./svc.sh install

# Start the service
./svc.sh start

# Download misc scripts
curl https://raw.githubusercontent.com/thecloudspark/scripts/main/self-hosted-runner-spot-instance/cleanup.sh > /actions-runner/cleanup.sh
curl https://raw.githubusercontent.com/thecloudspark/scripts/main/self-hosted-runner-spot-instance/checker.py > /actions-runner/checker.py
curl https://raw.githubusercontent.com/thecloudspark/scripts/main/self-hosted-runner-spot-instance/requirements.txt > /actions-runner/requirements.txt
chmod +x /actions-runner/cleanup.sh

# Install python packages
cd /actions-runner && pip install -r ./requirements.txt

# Add crontab entry
(crontab -l 2>/dev/null; echo "*/1 * * * * cd /actions-runner && python checker.py >>actions-cron.log 2>&1") | crontab -u ec2-user -
