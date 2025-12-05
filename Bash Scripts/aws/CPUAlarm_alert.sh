#!/bin/bash

# This script is to Check if an EC2 instance CPU usage > 80% (CloudWatch) and send an email alert using SNS.

aws cloudwatch describe-alarms-for-metric --metric-name CPUUtilization --namespace AWS/EC2 --dimensions Name=InstanceId,Value=i-0c986c72b3fEXAMPLE --query 'MetricAlarms[?StateValue==`ALARM`]' --output text | grep ALARM  > /dev/null 2>&1                


if [ $? -eq 0 ]; then
    echo "CPU usage is above threshold. Sending alert..."
    aws sns publish --topic-arn arn:aws:sns:us-east-1:123456789012:HighCPUAlertTopic --subject "High CPU Alert for EC2 Instance" --message "The CPU usage for EC2 instance i-0c986c72b3fEXAMPLE has exceeded the threshold of 80%."
else
    echo "CPU usage is within normal limits."
fi

# Note: Replace 'i-0c986c72b3fEXAMPLE' with your actual EC2 instance ID and 'arn:aws:sns:us-east-1:123456789012:HighCPUAlertTopic' with your actual SNS topic ARN.
# Make sure AWS CLI is configured with appropriate permissions to access CloudWatch and SNS.
