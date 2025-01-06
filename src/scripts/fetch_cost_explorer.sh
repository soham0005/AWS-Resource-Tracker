#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v3
# Purpose: Fetch detailed Cost Explorer information for the AWS Resource Tracker (7-day data)
########################

# Stop the script if any command fails
set -e

# Define paths explicitly
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
COST_EXPLORER_REPORT_DIR="$REPORT_DIR/cost_explorer"
LOG_FILE="$LOGS_DIR/aws_cron_log.txt"

# Ensure required directories exist
mkdir -p "$COST_EXPLORER_REPORT_DIR" "$LOGS_DIR"

# Log messages to the log file
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Generate a report file with the current date
REPORT_FILE="$COST_EXPLORER_REPORT_DIR/report-$(date "+%Y-%m-%d").txt"

# Fetch detailed Cost Explorer information (for last 7 days)
fetch_cost_explorer_info() {
    log_message "Fetching detailed Cost Explorer information for the last 7 days..."

    # Run AWS CLI command and store output
    if cost_info=$(aws ce get-cost-and-usage --time-period Start=$(date -d "7 days ago" +%Y-%m-%d),End=$(date +%Y-%m-%d) --granularity DAILY --metrics "BlendedCost" --group-by Type=DIMENSION,Key=SERVICE --query 'ResultsByTime[*].[TimePeriod.Start, TimePeriod.End, Groups[*].Keys, Groups[*].Metrics.BlendedCost.Amount]' --output text); then
        
        # Check if cost_info is empty (no data found)
        if [[ -z "$cost_info" ]]; then
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "No cost data found for the last 7 days."
            } > "$REPORT_FILE"
            log_message "No cost data found for the last 7 days."
            echo "No cost data found for the last 7 days."

        else
            {
                echo "####################"
                echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
                echo "####################"
                echo ""
                echo "Cost Explorer Information (Last 7 days):"
                echo "------------------------------------------"
                echo "Start Date | End Date | Service | Blended Cost"
                echo "------------------------------------------"
                echo "$cost_info" | while read line; do
                    start_date=$(echo $line | awk '{print $1}')
                    end_date=$(echo $line | awk '{print $2}')
                    service=$(echo $line | awk '{print $3}')
                    blended_cost=$(echo $line | awk '{print $4}')
                    # Only print if data exists
                    if [[ -n "$service" && -n "$blended_cost" ]]; then
                        echo "$start_date | $end_date | $service | \$ $blended_cost"
                    fi
                done
            } > "$REPORT_FILE"
            log_message "Successfully fetched Cost Explorer information for the last 7 days."
            echo "Successfully fetched Cost Explorer information for the last 7 days."
        fi

    else
        # If the AWS CLI command fails
        {
            echo "####################"
            echo "# DATE: $(date "+%Y-%m-%d") # Time: $(date "+%H:%M:%S")"
            echo "####################"
            echo ""
            echo "Error occurred while fetching Cost Explorer information for the last 7 days."
        } > "$REPORT_FILE"
        log_message "Error occurred while fetching Cost Explorer information for the last 7 days."
        exit 1  # Exit the script with error code
    fi
}

# Execute the Cost Explorer fetch function
fetch_cost_explorer_info
