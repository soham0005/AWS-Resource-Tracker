#!/bin/bash

# Install necessary dependencies (if any)
# Example: Install AWS CLI, Python, etc.
echo "Updating System"
sudo apt update
echo "Installing Snap"
sudo apt install snapd
echo "Installing AWS CLI"
sudo snap install aws-cli --classic
echo "Installing JQ for JSON Parser"
sudo apt install jq

# Set up the cron job (run main_script.sh daily)
echo "Setting CRON JOB for Daily Execution of Resource Tracker"
CRON_JOB="0 0 * * SUN /home/soham/aws-resource-tracker/main_script.sh"

# Check if the cron job already exists
(crontab -l | grep -F "$CRON_JOB") || (crontab -l; echo "$CRON_JOB") | crontab -

# Run the main script once to ensure everything works
echo "Installation Successful, Now follow the steps to configure AWS CLI in Readme.md"
# /home/soham/aws-resource-tracker/main_script.sh

