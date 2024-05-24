#!/bin/bash

LOG_FILE="/home/$USER/stress_test_log_$(date +"%Y-%m-%d_%H-%M-%S").txt"
STRESS_DURATION="1h"
LOG_INTERVAL="10s"

function collect_system_info {
    echo "Collecting system information..."
    echo "Timestamp: $(date)" >> "$LOG_FILE"
    echo "-----------------------------------" >> "$LOG_FILE"

    echo "CPU temperature:" >> "$LOG_FILE"
    sensors | grep "Core" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"

    echo "Disk I/O usage:" >> "$LOG_FILE"
    iostat -d -x 1 1 | awk 'NR==1; /nvme/' >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"

    echo "RAM usage:" >> "$LOG_FILE"
    free -m >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"

    echo "-----------------------------------" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

echo "Stress test log - $(date)" > "$LOG_FILE"
echo "-----------------------------------" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

start_time=$(date +%s)
end_time=$((start_time + 3600))

while [ $(date +%s) -lt $end_time ]; do
    echo "Running stress test..."
    stress --cpu 32 --io 4 --vm 8 --hdd 8 --hdd-bytes 20G --vm-bytes 60G --timeout "$STRESS_DURATION" &

    stress_pid=$!

    while [ $(date +%s) -lt $((start_time + 3600)) ]; do
        collect_system_info
        sleep $LOG_INTERVAL
    done

    echo "Stopping stress test..."
    kill -SIGINT $stress_pid
    wait $stress_pid
    echo "Waiting for next test iteration..."
    sleep 1
done

echo "Stress test completed."
