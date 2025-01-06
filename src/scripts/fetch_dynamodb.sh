#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch DynamoDB information for the AWS Resource Tracker
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
DYNAMODB_REPORT_DIR="$REPORT_DIR/dynamodb"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$DYNAMODB_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$DYNAMODB_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch DynamoDB information
fetch_dynamodb_info() {
    log_message "Fetching DynamoDB information..."

    # Run AWS CLI command and store output for table details
    if dynamodb_info=$(aws dynamodb list-tables --query 'TableNames' --output text); then

        # Check if dynamodb_info is empty (no tables found)
        if [[ -z "$dynamodb_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No DynamoDB tables found."
            } > "$REPORT_FILE"
            log_message "No DynamoDB tables found."
            echo "No DynamoDB tables found."

        else
            # If tables exist, fetch details for each table
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "DynamoDB Table Information:"
                echo "----------------------------"
                echo "Table Name | Provisioned Read Capacity | Provisioned Write Capacity | Item Count | Table Size (Bytes)"
                echo "---------------------------------------------------------------"
                for table in $dynamodb_info; do
                    # Fetch details for each table
                    table_details=$(aws dynamodb describe-table --table-name "$table" --query 'Table.[TableName,ProvisionedThroughput.ReadCapacityUnits,ProvisionedThroughput.WriteCapacityUnits,ItemCount,TableSizeBytes]' --output text)
                    if [[ -n "$table_details" ]]; then
                        echo "$table_details"
                    fi
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched DynamoDB information."
            echo "Successfully fetched DynamoDB information."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching DynamoDB information."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching DynamoDB information."
        exit 1  # Exit the script with error code
    fi
}

# Execute the DynamoDB fetch function
fetch_dynamodb_info
