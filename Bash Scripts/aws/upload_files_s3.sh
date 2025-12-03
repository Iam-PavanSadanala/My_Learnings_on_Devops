#!/bin/bash

: ' Script to upload files in a specified local directory to an AWS S3 bucket. '

set -euo pipefail

# Variables
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <local_directory>"
    echo "Please provide the local directory containing files to upload."
    exit 1
fi

Local_Dir="$1"

s3_Uri="s3://onepiece-2025/test/"

echo "Copying files from $Local_Dir to $s3_Uri ..."

aws s3 cp "$Local_Dir" "$s3_Uri" --recursive

#aws s3 rm "$s3_Uri" --recursive