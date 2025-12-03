#!/bin/bash

# This script lists all EC2 instances in the specified AWS region.

# ...existing code...
set -euo pipefail

echo "Listing EC2 instances in ap-south-1..."
aws ec2 describe-instances --region ap-south-1 --query 'Reservations[*].Instances[*].{InstanceID:InstanceId,OS:PlatformDetails,Type:InstanceType,LaunchTime:LaunchTime}' --output table
# ...existing code...