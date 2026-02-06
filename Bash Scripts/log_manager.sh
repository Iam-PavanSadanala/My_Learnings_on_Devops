#!/bin/bash

###################################################
#Author : Pavan Sadanala
# Description: This script manages log files in a specified directory. It identifies log files that are older than a certain number of days and larger than a specified size, then prompts the user for confirmation before deleting them. The script also logs its actions to a log file.
# Usage: ./log_manager.sh <log_dir> <days> <size_MB>
# Example: ./log_manager.sh /var/log 30 100
# Created on: 2026-02-06
###################################################
set -euo pipefail

# ------------------------
# Argument validation
# ------------------------
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <log_dir> <days> <size_MB>"
    exit 1
fi

LOG_DIR="$1"
DAYS="$2"
SIZE="$3"
LOG_FILE="/var/log/log_manager.log"

# Directory check
if [ ! -d "$LOG_DIR" ]; then
    echo "Directory $LOG_DIR does not exist."
    exit 1
fi

# Integer validation
if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    echo "Days must be a positive integer."
    exit 1
fi

if ! [[ "$SIZE" =~ ^[0-9]+$ ]]; then
    echo "Size must be a positive integer."
    exit 1
fi

# ------------------------
# Find log files
# ------------------------
oldfiles=$(find "$LOG_DIR" -type f -name "*.log" -size +"${SIZE}M" -mtime +"$DAYS" -exec du -h {} \;)

if [ -z "$oldfiles" ]; then
    echo "No log files older than $DAYS days and larger than $SIZE MB found."
    exit 0
fi

echo "Found $(echo "$oldfiles" | wc -l) log files:"
echo "$oldfiles"

# ------------------------
# Confirmation
# ------------------------
read -r -p "Do you want to delete these files? (yes/no): " answer

if [[ "$answer" == "yes" ]]; then
    find "$LOG_DIR" -type f -name "*.log" -size +"${SIZE}M" -mtime +"$DAYS" -exec rm -f {} \;
    echo "$(date '+%F %T') | DELETED | Logs older than $DAYS days" >> "$LOG_FILE"
    echo "Files deleted successfully."
else
    echo "No files were deleted."
fi
