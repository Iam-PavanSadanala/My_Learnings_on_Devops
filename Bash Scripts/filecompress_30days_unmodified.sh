#!/bin/bash

# Build a script that finds files older than 30 days in /var/log and compresses them.

if [ $# -ne 1 ];then
    echo "Usage: $0 <directory>"
    exit 1
fi

path="$1"

if [ -d  "$path" ];then
    echo "DIrectory exists"
else
    echo "Directory does not exist"
    exit 1
    fi

find "$path" -type f -mtime +30 -exec gzip {} \;

echo "Compression completed"
