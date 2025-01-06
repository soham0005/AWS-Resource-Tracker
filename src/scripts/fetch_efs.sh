#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch EFS file system information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
EFS_REPORT_DIR="$REPORT_DIR/efs"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$EFS_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$EFS_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch EFS information
fetch_efs_info() {
    log_message "Fetching EFS file system information..."

    # Run AWS CLI command and store output for EFS file system details
    if efs_info=$(aws efs describe-file-systems --query 'FileSystems[*].[FileSystemId,CreationTime,SizeInBytes,PerformanceMode,Encrypted]' --output text); then

        # Check if efs_info is empty (no file systems found)
        if [[ -z "$efs_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No EFS file systems found."
            } > "$REPORT_FILE"
            log_message "No EFS file systems found."
            echo "No EFS file systems found."

        else
            # If file systems exist, fetch details for each file system
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "EFS File System Information:"
                echo "---------------------------------------------------------------"
                echo "File System ID | Creation Time | Size (Bytes) | Performance Mode | Encrypted"
                echo "---------------------------------------------------------------"
                echo "$efs_info" | while read line; do
                    file_system_id=$(echo $line | awk '{print $1}')
                    creation_time=$(echo $line | awk '{print $2}')
                    size_in_bytes=$(echo $line | awk '{print $3}')
                    performance_mode=$(echo $line | awk '{print $4}')
                    encrypted=$(echo $line | awk '{print $5}')
                    
                    # Format the creation time
                    formatted_creation_time=$(date -d "$creation_time" "+%Y-%m-%d %H:%M:%S")
                    
                    # Only print if data exists
                    echo "$file_system_id | $formatted_creation_time | $size_in_bytes | $performance_mode | $encrypted"
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched EFS file system information."
            echo "Successfully fetched EFS file system information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching EFS file system information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching EFS file system information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the EFS fetch function
fetch_efs_info
