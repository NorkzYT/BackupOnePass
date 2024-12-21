#!/bin/bash

echo "Starting to monitor 1Password logs..."

# Define the path to the log file.
LOG_FILE="/home/ubuntu/.config/1Password/logs/1Password_rCURRENT.log"

# Function to monitor 1Password log for a specific line.
monitor_logs_for_line() {
    local search_line="$1"
    local timeout="$2"
    local start_time
    start_time=$(date +%s)

    echo "Starting to monitor 1Password logs..."

    # Check if the log file exists.
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "Error: Log file does not exist at path: $LOG_FILE" >&2
        return 1
    else
        echo "Log file found: $LOG_FILE"
    fi

    # Loop until the line is found or timeout is reached.
    while true; do
        # Check if the current time is greater than start time + timeout.
        if [[ $(($(date +%s) - start_time)) -gt timeout ]]; then
            echo "Timeout reached while monitoring logs." >&2
            return 1
        fi

        # Use grep to search for the line in the log file.
        if grep -q "$search_line" "$LOG_FILE"; then
            echo "Detected desired line in logs: '$search_line'"
            return 0
        fi

        sleep 1
    done
}

# Function to monitor 1Password log for a specific line that is more recent.
monitor_logs_for_current_line() {
    local search_line="$1"
    local timeout="$2"
    local start_time
    start_time=$(date +%s)

    echo "Starting to monitor 1Password logs for new occurrences..."

    # Check if the log file exists.
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "Error: Log file does not exist at path: $LOG_FILE" >&2
        return 1
    else
        echo "Log file found: $LOG_FILE"
    fi

    # Use tail to follow the log file dynamically.
    tail -n 0 -f "$LOG_FILE" | while read -r line; do
        # Check for timeout.
        if [[ $(($(date +%s) - start_time)) -gt timeout ]]; then
            echo "Timeout reached while monitoring logs." >&2
            return 1
        fi

        # Check if the current line matches the desired line.
        if echo "$line" | grep -q "$search_line"; then
            echo "Detected desired line in logs: '$search_line'"
            pkill -P $$ tail  # Terminate the tail process.
            return 0
        fi
    done
}
