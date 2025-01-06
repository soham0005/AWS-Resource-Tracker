#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch S3 bucket information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
S3_REPORT_DIR="$REPORT_DIR/s3"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$S3_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$S3_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch S3 bucket information
fetch_s3_info() {
    log_message "Fetching S3 bucket information..."

    # Run AWS CLI command and store output for S3 bucket details
    if s3_info=$(aws s3api list-buckets --query 'Buckets[*].[Name,CreationDate]' --output text); then

        # Check if s3_info is empty (no S3 buckets found)
        if [[ -z "$s3_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No S3 buckets found."
            } > "$REPORT_FILE"
            log_message "No S3 buckets found."
            echo "No S3 buckets found."

        else
            # If S3 buckets exist, fetch details for each
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "S3 Bucket Information:"
                echo "-----------------------------------------------------------"
                echo "Bucket Name | Creation Date"
                echo "-----------------------------------------------------------"
                echo "$s3_info" | while read line; do
                    bucket_name=$(echo $line | awk '{print $1}')
                    creation_date=$(echo $line | awk '{print $2}')
                    
                    # Format the creation time
                    formatted_creation_date=$(date -d "$creation_date" "+%Y-%m-%d %H:%M:%S")
                    
                    # Only print if data exists
                    echo "$bucket_name | $formatted_creation_date"
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched S3 bucket information."
            echo "Successfully fetched S3 bucket information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching S3 bucket information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching S3 bucket information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the S3 fetch function
fetch_s3_info
