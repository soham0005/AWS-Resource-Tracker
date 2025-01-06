#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch Lambda function information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
LAMBDA_REPORT_DIR="$REPORT_DIR/lambda"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$LAMBDA_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$LAMBDA_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch Lambda function information
fetch_lambda_info() {
    log_message "Fetching Lambda function information..."

    # Run AWS CLI command and store output for Lambda function details
    if lambda_info=$(aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime,LastModified,Handler]' --output text); then

        # Check if lambda_info is empty (no Lambda functions found)
        if [[ -z "$lambda_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No Lambda functions found."
            } > "$REPORT_FILE"
            log_message "No Lambda functions found."
            echo "No Lambda functions found."

        else
            # If Lambda functions exist, fetch details for each
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "Lambda Function Information:"
                echo "-----------------------------------------------------------"
                echo "Function Name | Runtime | Last Modified | Handler"
                echo "-----------------------------------------------------------"
                echo "$lambda_info" | while read line; do
                    function_name=$(echo $line | awk '{print $1}')
                    runtime=$(echo $line | awk '{print $2}')
                    last_modified=$(echo $line | awk '{print $3}')
                    handler=$(echo $line | awk '{print $4}')
                    
                    # Format the last modified time
                    formatted_last_modified=$(date -d "$last_modified" "+%Y-%m-%d %H:%M:%S")
                    
                    # Only print if data exists
                    echo "$function_name | $runtime | $formatted_last_modified | $handler"
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched Lambda function information."
            echo "Successfully fetched Lambda function information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching Lambda function information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching Lambda function information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the Lambda fetch function
fetch_lambda_info
