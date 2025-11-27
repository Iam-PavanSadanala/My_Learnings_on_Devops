#!/bin/bash

THRESHOLD=80

echo "Checking disk usage..."
echo "---------------------------------"

# Loop through all mounted filesystems
df -h | grep -vE 'Filesystem|tmpfs|devtmpfs' | while read line; do
    USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')   # Extract "%" and remove symbol
    PARTITION=$(echo $line | awk '{print $6}')             # Mount point

    if [ "$USAGE" -gt "$THRESHOLD" ]; then
        echo "WARNING: Disk usage on $PARTITION is at ${USAGE}% (Threshold: ${THRESHOLD}%)"
         
    fi
done
echo "Disk usage is less than $THRESHOLD"
