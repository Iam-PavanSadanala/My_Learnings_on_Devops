#!/bin/bash
set -euo pipefail

REGION="ap-south-1"
LOG_FILE="/var/log/ec2_scheduler.log"

CURRENT_MIN=$(date +%M)
CURRENT_HOUR=$(date +%H)
CURRENT_WDAY=$(date +%u)

matches_schedule() {
    local cron_min=$1
    local cron_hour=$2
    local cron_wday=$3

    [[ "$cron_min" == "*" || "$cron_min" == "$CURRENT_MIN" ]] &&
    [[ "$cron_hour" == "*" || "$cron_hour" == "$CURRENT_HOUR" ]] &&
    [[ "$cron_wday" == "*" || "$cron_wday" == "$CURRENT_WDAY" ]]
}


log() {
    echo "$(date '+%F %T') | $1" | tee -a "$LOG_FILE"
}

INSTANCES=$(aws ec2 describe-instances \
  --region "$REGION" \
  --query "Reservations[].Instances[].[InstanceId,State.Name,Tags]" \
  --output json)

echo "$INSTANCES" | jq -c '.[]' | while read -r inst; do
    ID=$(echo "$inst" | jq -r '.[0]')
    STATE=$(echo "$inst" | jq -r '.[1]')

    START_TAG=$(echo "$inst" | jq -r '.[2][] | select(.Key=="StartSchedule") | .Value' 2>/dev/null || true)
    STOP_TAG=$(echo "$inst" | jq -r '.[2][] | select(.Key=="StopSchedule") | .Value' 2>/dev/null || true)

    if [ -n "$START_TAG" ] && [ "$STATE" = "stopped" ]; then
        read -r SM SH SD SMON SW <<< "$START_TAG"
        if matches_schedule "$SM" "$SH" "$SW"; then
            log "Starting instance $ID"
            aws ec2 start-instances --region "$REGION" --instance-ids "$ID"
        fi
    fi

    if [ -n "$STOP_TAG" ] && [ "$STATE" = "running" ]; then
        read -r EM EH ED EMON EW <<< "$STOP_TAG"
        if matches_schedule "$EM" "$EH" "$EW"; then
            log "Stopping instance $ID"
            aws ec2 stop-instances --region "$REGION" --instance-ids "$ID"
        fi
    fi
done
