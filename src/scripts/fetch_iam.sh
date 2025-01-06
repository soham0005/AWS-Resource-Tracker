#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch IAM information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
IAM_REPORT_DIR="$REPORT_DIR/iam"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$IAM_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$IAM_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch IAM information
fetch_iam_info() {
    log_message "Fetching IAM information..."

    # Run AWS CLI command and store output for IAM user details
    if iam_info=$(aws iam list-users --query 'Users[*].[UserName,CreateDate,Arn]' --output text); then

        # Check if iam_info is empty (no users found)
        if [[ -z "$iam_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No IAM users found."
            } > "$REPORT_FILE"
            log_message "No IAM users found."
            echo "No IAM users found."

        else
            # If IAM users exist, fetch details for each
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "IAM User Information:"
                echo "-----------------------------------------------------------"
                echo "User Name | Creation Date | ARN"
                echo "-----------------------------------------------------------"
                echo "$iam_info" | while read line; do
                    user_name=$(echo $line | awk '{print $1}')
                    creation_date=$(echo $line | awk '{print $2}')
                    arn=$(echo $line | awk '{print $3}')
                    
                    # Format the creation time
                    formatted_creation_date=$(date -d "$creation_date" "+%Y-%m-%d %H:%M:%S")
                    
                    # Only print if data exists
                    echo "$user_name | $formatted_creation_date | $arn"
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched IAM information."
            echo "Successfully fetched IAM information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching IAM information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching IAM information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the IAM fetch function
fetch_iam_info
