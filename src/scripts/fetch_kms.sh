#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch KMS key information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
KMS_REPORT_DIR="$REPORT_DIR/kms"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$KMS_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$KMS_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch KMS information
fetch_kms_info() {
    log_message "Fetching KMS key information..."

    # Run AWS CLI command and store output for KMS key details
    if kms_info=$(aws kms list-keys --query 'Keys' --output text); then

        # Check if kms_info is empty (no keys found)
        if [[ -z "$kms_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No KMS keys found."
            } > "$REPORT_FILE"
            log_message "No KMS keys found."
            echo "No KMS keys found."

        else
            # If KMS keys exist, fetch details for each
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "KMS Key Information:"
                echo "-----------------------------------------------------------"
                echo "Key ID | Key ARN | Creation Date"
                echo "-----------------------------------------------------------"
                for key in $kms_info; do
                    key_details=$(aws kms describe-key --key-id "$key" --query 'KeyMetadata[].[KeyId,Arn,CreationDate]' --output text)
                    
                    key_id=$(echo $key_details | awk '{print $1}')
                    arn=$(echo $key_details | awk '{print $2}')
                    creation_date=$(echo $key_details | awk '{print $3}')
                    
                    # Format the creation time
                    formatted_creation_date=$(date -d "$creation_date" "+%Y-%m-%d %H:%M:%S")
                    
                    # Only print if data exists
                    echo "$key_id | $arn | $formatted_creation_date"
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched KMS key information."
            echo "Successfully fetched KMS key information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching KMS key information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching KMS key information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the KMS fetch function
fetch_kms_info
