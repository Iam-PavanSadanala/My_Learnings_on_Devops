#!/bin/bash

set -euo pipefail
# Create EBS volume and attach it to an instance

#variables
availability_zone="$1"
Instance_ID="i-0408f1235c8dd6833"

if [ -z "$availability_zone" ]; then
    echo "Usage: $0 <availability-zone>"
    exit 1
fi

echo "Creating EBS volume in availability zone: $availability_zone"
# create a volume of size 10 GB in the AZ of type gp3
volume_ID="$(aws ec2 create-volume --volume-type gp3  --size 10  --availability-zone "$availability_zone" --query 'VolumeId' --output text)"
echo "Created volume : $volume_ID"

# wait until the volume is available
echo "Waiting for volume to become available..."
aws ec2 wait volume-available --volume-ids "$volume_ID"

# attach the created volume to an instance
echo "Attaching volume $volume_ID to instance $Instance_ID"
aws ec2 attach-volume --volume-id "$volume_ID" --instance-id "$Instance_ID" --device /dev/sda2

echo "Volume $volume_ID attached to instance $Instance_ID successfully."
# Note: Replace 'i-0408f1235c8dd6833' with your actual EC2 instance ID.