#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch ELB information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
ELB_REPORT_DIR="$REPORT_DIR/elb"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$ELB_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$ELB_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch ELB information
fetch_elb_info() {
    log_message "Fetching ELB information..."

    # Run AWS CLI command and store output for ELB details
    if elb_info=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].[LoadBalancerName,DNSName,ListenerDescriptions[*].Listener.Port,CreatedTime]' --output text); then

        # Check if elb_info is empty (no ELB found)
        if [[ -z "$elb_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No ELB found."
            } > "$REPORT_FILE"
            log_message "No ELB found."
            echo "No ELB found."

        else
            # If ELBs exist, fetch details for each
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "ELB Information:"
                echo "------------------------------------------------------"
                echo "Load Balancer Name | DNS Name | Port | Creation Time"
                echo "------------------------------------------------------"
                echo "$elb_info" | while read line; do
                    lb_name=$(echo $line | awk '{print $1}')
                    dns_name=$(echo $line | awk '{print $2}')
                    port=$(echo $line | awk '{print $3}')
                    created_time=$(echo $line | awk '{print $4}')
                    
                    # Format the creation time
                    formatted_creation_time=$(date -d "$created_time" "+%Y-%m-%d %H:%M:%S")
                    
                    # Only print if data exists
                    echo "$lb_name | $dns_name | $port | $formatted_creation_time"
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched ELB information."
            echo "Successfully fetched ELB information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching ELB information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching ELB information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the ELB fetch function
fetch_elb_info
