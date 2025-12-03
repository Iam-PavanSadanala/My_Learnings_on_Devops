#!/bin/bash

# Script to monitor disk usage on given mount

if [ $# -ne 1 ]; then
   echo "Usage of script is : $0 <mount_point>"
fi

mount_point="$1"
Threshold=80

# Check if the mount point exists
if ! findmnt "$mount_point" > /dev/null 2>&1; then
    echo "Mount point $mount_point does not exist."
    exit 1
fi


usage=$(df -h "$mount_point" | awk 'NR==2 {print $5}' | sed 's/%//')

if [ usage -eq "No such file or directory" ]; then
    echo "Mount point $mount_point does not exist."
    exit 1
fi

if [ $usage -gt $Threshold ]; then
    echo "Disk usage on $mount_point is above threshold: $usage%"
    else
    echo "Disk usage on $mount_point is within limits: $usage%"
fi
