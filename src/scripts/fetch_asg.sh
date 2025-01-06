#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch Auto Scaling Groups (ASG) information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
ASG_REPORT_DIR="$REPORT_DIR/asg"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$ASG_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$ASG_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch Auto Scaling Groups information
fetch_asg_info() {
    log_message "Fetching Auto Scaling Groups information..."

    # Run AWS CLI command and store output
    if asg_info=$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[*].[AutoScalingGroupName, MinSize, MaxSize, DesiredCapacity, Instances[].InstanceId]' --output text); then
        
        # Check if asg_info is empty (no ASG found)
        if [[ -z "$asg_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No active Auto Scaling Groups found."
            } > "$REPORT_FILE"
            log_message "No active Auto Scaling Groups found."
            echo "Successfully fetched Auto Scaling Groups information."

        else
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "Auto Scaling Groups Information:"
                echo "----------------------------------"
                echo "$asg_info"
            } > "$REPORT_FILE"
            log_message "Successfully fetched Auto Scaling Groups information."
            echo "Successfully fetched Auto Scaling Groups information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching Auto Scaling Groups information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching Auto Scaling Groups information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the ASG fetch function
fetch_asg_info
