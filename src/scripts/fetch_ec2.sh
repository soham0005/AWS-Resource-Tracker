#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch EC2 instances information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
EC2_REPORT_DIR="$REPORT_DIR/ec2"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$EC2_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$EC2_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch EC2 instances information
fetch_ec2_info() {
    log_message "Fetching EC2 instances information..."

    # Run AWS CLI command and store output
    if ec2_info=$(aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId, LaunchTime, State.Name, InstanceType, PublicIpAddress]' --output text); then
        
        # Check if ec2_info is empty (no instances found)
        if [[ -z "$ec2_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No active EC2 instances found."
            } > "$REPORT_FILE"
            log_message "No active EC2 instances found."
            echo "Successfully fetched EC2 instances information and saved to $REPORT_FILE."

        else
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "EC2 Instances Information:"
                echo "----------------------------"
                echo "$ec2_info"
            } > "$REPORT_FILE"
            log_message "Successfully fetched EC2 instances information and saved to $REPORT_FILE."
            echo "Successfully fetched EC2 instances information and saved to $REPORT_FILE."
        fi

    else
        # If the AWS CLI command itself fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching EC2 instances."
        } > "$REPORT_FILE"
        log_message "Error occurred while running AWS CLI command for EC2."
        exit 1  # Exit the script with error code
    fi
}

# Execute the EC2 info fetch function
fetch_ec2_info
