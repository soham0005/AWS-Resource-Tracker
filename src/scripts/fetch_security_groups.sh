#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch Security Groups information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
SG_REPORT_DIR="$REPORT_DIR/security-groups"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$SG_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$SG_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch Security Groups information
fetch_sg_info() {
    log_message "Fetching Security Groups information..."

    # Run AWS CLI command and store output for Security Groups details
    if sg_info=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupName,GroupId,Description]' --output text); then

        # Check if sg_info is empty (no security groups found)
        if [[ -z "$sg_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No security groups found."
            } > "$REPORT_FILE"
            log_message "No security groups found."
            echo "No security groups found."

        else
            # If security groups exist, fetch details for each
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "Security Group Information:"
                echo "-----------------------------------------------------------"
                echo "Group Name | Group ID | Description"
                echo "-----------------------------------------------------------"
                echo "$sg_info" | while read line; do
                    group_name=$(echo $line | awk '{print $1}')
                    group_id=$(echo $line | awk '{print $2}')
                    description=$(echo $line | awk '{print $3}')
                    
                    # Only print if data exists
                    echo "$group_name | $group_id | $description"
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched Security Groups information."
            echo "Successfully fetched Security Groups information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching Security Groups information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching Security Groups information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the Security Groups fetch function
fetch_sg_info
