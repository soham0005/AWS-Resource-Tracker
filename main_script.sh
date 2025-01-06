#!/bin/bash

########################
# Author: Soham Adhyapak
# Date: 5th January 2025
# Version: v1
# Purpose: Main script to trigger all service-specific scripts for AWS Resource Tracker
########################

# Stops the script as soon as any command fails
set -e

# Log file path
LOG_FILE="/home/soham/aws-resource-tracker/logs/aws_cron_log.txt"

# Base directory for the project
BASE_DIR="/home/soham/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
ARCHIVE_DIR="$BASE_DIR/archive"
LOGS_DIR="$BASE_DIR/logs"

# AWS Services to track
SERVICES=("ec2" "s3" "iam" "lambda" "dynamodb" "ebs" "asg" "efs" "security_groups" "kms" "elb" "api_gateway" "cost_explorer")

# Ensure that the required directories exist, or create them if not
ensure_directories_exist() {
    echo "Ensuring required directories exist..."
    mkdir -p "$REPORT_DIR" "$ARCHIVE_DIR" "$LOGS_DIR"

    for service in "${SERVICES[@]}"; do
        mkdir -p "$REPORT_DIR/$service"
        mkdir -p "$ARCHIVE_DIR/$service"
    done

    echo "Directories ensured." >> "$LOG_FILE"
}

# Log messages with timestamp to log file
log_message() {
    local message=$1
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Ensure that each service script is executable
ensure_executable_permission() {
    for service in "${SERVICES[@]}"; do
        script_path="$BASE_DIR/src/scripts/fetch_$service.sh"
        
        # Check if the script exists and is executable
        if [[ -f "$script_path" && ! -x "$script_path" ]]; then
            log_message "Granting execution permission to $script_path"
            chmod +x "$script_path"  # Grant execution permission
        fi
    done

    echo "Executable permissions ensured for all service scripts." >> "$LOG_FILE"
}

# Run individual service scripts
run_service_scripts() {
    echo "Running service scripts..."
    for service in "${SERVICES[@]}"; do
        script_path="$BASE_DIR/src/scripts/fetch_$service.sh"
        
        log_message "Attempting to run script for $service at $script_path"
        echo "Attempting to run script for $service at $script_path"

        # Check if the script is executable
        if [[ -x "$script_path" ]]; then
            log_message "Running script for $service..."
            echo "Running script for $service..."
            
            bash "$script_path" >> "$LOG_FILE" 2>&1
            
            if [[ $? -eq 0 ]]; then
                log_message "Successfully executed script for $service."
                echo "Successfully executed script for $service."
            else
                log_message "Error occurred while executing script for $service."
                echo "Error occurred while executing script for $service."
            fi
        else
            log_message "Error: $script_path is not executable or does not exist."
            echo "Error: $script_path is not executable or does not exist."
        fi
    done
}

# Archive reports at the end of the week (compressing 7 days of reports for each service)
archive_reports() {
    echo "Archiving weekly reports..."
    for service in "${SERVICES[@]}"; do
        current_date=$(date "+%Y-%m-%d")
        start_date=$(date -d "7 days ago" "+%Y-%m-%d")

        # Create a tarball for the past week reports
        tar -czf "$ARCHIVE_DIR/$service/report-${start_date}-to-${current_date}.tar.gz" -C "$REPORT_DIR/$service" .

        log_message "Archived weekly report for $service from $start_date to $current_date."
    done
}

# Main process
main() {
    log_message "Starting main script execution..."

    ensure_directories_exist
    ensure_executable_permission  # Ensure scripts have execution permission
    run_service_scripts

    day_of_week=$(date +%u)  # 1=Monday, 7=Sunday
    if [ "$day_of_week" -eq 7 ]; then
        archive_reports
    fi

    log_message "Main script execution completed."
}

main
