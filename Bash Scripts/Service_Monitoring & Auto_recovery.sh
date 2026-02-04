#!/bin/bash

# Root check
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Services to monitor
services=("ssh" "jenkins")

# Log file
log_file="/var/log/service_monitor.log"

check_services() {
    echo "Checking status of services..."

    # Ensure log file exists
    [ ! -f "$log_file" ] && touch "$log_file"

    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            echo "$(date): $svc is running." >> "$log_file"
        else
            echo "$(date): $svc is not running. Attempting restart..." >> "$log_file"
            systemctl restart "$svc"

            if systemctl is-active --quiet "$svc"; then
                echo "$(date): $svc restarted successfully." >> "$log_file"
            else
                echo "$(date): FAILED to restart $svc." >> "$log_file"
            fi
        fi
    done
}

send_alert_mail() {
    RECIPIENT="pavansadanala77@gmail.com"
    SUBJECT="Service Restart Failure - Attention Needed"
    BODY="Hello,

One or more services failed to restart.
Please check the log file at:
$log_file
"

    echo "$BODY" | mail -s "$SUBJECT" "$RECIPIENT"
}

# Run checks
check_services

# Alert if failure found
if grep -qi "FAILED" "$log_file"; then
    send_alert_mail
else
    echo "All services are running fine."
    exit 0
fi
