# AWS Resource Tracker

## Overview

The **AWS Resource Tracker** is a script-based solution for tracking and reporting various AWS services. It generates daily reports for specified AWS services, saves them to individual service folders, and compresses them into weekly archives. The project is designed to help AWS users monitor their resources and keep track of their usage and configurations.

### Key Features:

- Tracks multiple AWS services such as EC2, S3, IAM, Lambda, EBS, DynamoDB, and more.
- Generates daily reports for each tracked service.
- Archives weekly reports into compressed files.
- Logs the execution and results of each service fetch operation.

## List of AWS Services Tracked

This project tracks the following AWS services:

- EC2 (Elastic Compute Cloud)
- S3 (Simple Storage Service)
- IAM (Identity and Access Management)
- Lambda
- DynamoDB
- EBS (Elastic Block Store)
- ASG (Auto Scaling Groups)
- EFS (Elastic File System)
- Security Groups
- KMS (Key Management Service)
- ELB (Elastic Load Balancer)
- API Gateway
- Cost Explorer

## Installation Instructions

### 1. Clone the Repository

To start using the AWS Resource Tracker, you first need to clone the repository to your local machine.

```bash
git clone https://github.com/your-username/aws-resource-tracker.git
cd aws-resource-tracker
```
### 2. Run the Installer with Execution Permissions 
The installer will set up the necessary environment and dependencies for the project.

```bash
chmod +x installer.sh
./installer.sh
```
This will:

- Install required dependencies.
- Set up directories and files.
- Set cron jobs to run the main script daily.

### 3. Configure AWS CLI

Before running the main script, ensure that your AWS CLI is properly configured with your AWS credentials and region.

To configure AWS CLI, run the following command:

```bash
aws configure
```
This will prompt you for the following:
AWS Access Key ID: Your AWS access key.

- AWS Secret Access Key: Your AWS secret key.
- Default region name: The AWS region you want to use (e.g., us-east-1).
- Default output format: Recommended as json.

### 4. Update Paths in Scripts
Update these paths according to your system.

Open each script in the src/scripts/ folder.

Update the following paths:

- BASE_DIR: The root directory of the project.
- REPORT_DIR: The directory where reports will be stored.
- LOGS_DIR: The directory where logs will be stored.

Example:

```bash
BASE_DIR="/home/user/aws-resource-tracker"
REPORT_DIR="$BASE_DIR/reports"
LOGS_DIR="$BASE_DIR/logs"
```

### 5. Grant Execution Permissions to Main Script
Ensure the main script (main_script.sh) has execution permissions.

```bash
chmod +x main_script.sh
```
### 6. Run the Main Script
Now you're ready to run the main script. This will fetch information for all the tracked services, generate daily reports, and log the results.

```bash
./main_script.sh
```
The script will:

- Create the necessary directories if they do not exist.
- Check for the required execution permissions on service scripts.
- Run each service-specific script (e.g., fetch_ec2.sh, fetch_s3.sh, etc.) one by one.
- Archive weekly reports at the end of each week.
