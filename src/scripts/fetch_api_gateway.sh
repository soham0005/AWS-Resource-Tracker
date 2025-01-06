#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch API Gateway Information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
API_GATEWAY_REPORT_DIR="$REPORT_DIR/api_gateway"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$API_GATEWAY_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$API_GATEWAY_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch API Gateway information
fetch_api_gateway_info() {
    log_message "Fetching API Gateway information..."

    # Run AWS CLI command and store output
    if api_info=$(aws apigateway get-rest-apis --query 'items[].{Name:name, ID:id}' --output text); then
        
        # Check if api_info is empty (no APIs found)
        if [[ -z "$api_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No active API Gateways found."
            } > "$REPORT_FILE"
            log_message "No active API Gateways found."
            echo "Successfully fetched API Gateway information and Saved into file"

        else
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "API Gateway Information:"
                echo "----------------------------"
                echo "$api_info"
            } > "$REPORT_FILE"
            log_message "Successfully fetched API Gateway information."
            echo "Successfully fetched API Gateway information and Saved into file"
        fi

    else
        # If the AWS CLI command itself fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching API Gateway information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching API Gateway information."
        echo "Error Occurred while fetching API Gateway Information"

        exit 1  # Exit the script with error code
    fi
}

# Execute the API Gateway fetch function
fetch_api_gateway_info
