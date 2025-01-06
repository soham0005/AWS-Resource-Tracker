#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch EBS volume information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
EBS_REPORT_DIR="$REPORT_DIR/ebs"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$EBS_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$EBS_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch EBS volume information
fetch_ebs_info() {
    log_message "Fetching EBS volume information..."

    # Run AWS CLI command and store output for EBS volume details
    if ebs_info=$(aws ec2 describe-volumes --query 'Volumes[*].[VolumeId,Size,VolumeType,State,Attachment.State,Attachment.InstanceId]' --output text); then

        # Check if ebs_info is empty (no volumes found)
        if [[ -z "$ebs_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No EBS volumes found."
            } > "$REPORT_FILE"
            log_message "No EBS volumes found."
            echo "No EBS volumes found."

        else
            # If volumes exist, fetch details for each volume
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "EBS Volume Information:"
                echo "----------------------------------------------------------"
                echo "Volume ID | Size (GiB) | Volume Type | State | Attachment State | Instance ID"
                echo "----------------------------------------------------------"
                echo "$ebs_info" | while read line; do
                    volume_id=$(echo $line | awk '{print $1}')
                    size=$(echo $line | awk '{print $2}')
                    volume_type=$(echo $line | awk '{print $3}')
                    state=$(echo $line | awk '{print $4}')
                    attachment_state=$(echo $line | awk '{print $5}')
                    instance_id=$(echo $line | awk '{print $6}')
                    
                    # Only print if data exists
                    echo "$volume_id | $size | $volume_type | $state | $attachment_state | $instance_id"
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched EBS volume information."
            echo "Successfully fetched EBS volume information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching EBS volume information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching EBS volume information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the EBS fetch function
fetch_ebs_info
