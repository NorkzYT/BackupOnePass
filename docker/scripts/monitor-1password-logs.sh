#!/bin/bash

echo "Starting to monitor 1Password logs..."

LOG_FILE="/home/ubuntu/.config/1Password/logs/1Password_rCURRENT.log"

# Check if the log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file does not exist at path: $LOG_FILE" >&2
    exit 1
else
    echo "Log file found: $LOG_FILE"
fi

# Use a named pipe for tailing logs in the background
pipe=/tmp/$$.tmp
echo "Creating a named pipe at $pipe for tailing the log file..."
mkfifo "$pipe"

cleanup() {
    echo "Cleaning up: removing the named pipe $pipe."
    rm -f "$pipe"
}

# Register the cleanup function to execute on script exit
trap cleanup EXIT

monitor_logs_for_line() {
    local search_line="$1"
    echo "Monitoring log file for the presence of line: '$search_line'"

    # Tail the log file in the background, redirecting its output to the named pipe
    tail -n 0 -F "$LOG_FILE" >"$pipe" &
    local tail_pid=$!
    echo "Tailing process started with PID: $tail_pid"

    # Read from the named pipe in a loop
    while IFS= read -r line; do
        # For logging purposes, uncomment the following line if needed
        echo "Log: $line"
        if [[ "$line" == *"$search_line"* ]]; then
            echo "Detected desired line in logs: '$search_line'"
            kill "$tail_pid"
            break
        fi
    done <"$pipe"

    echo "Monitoring completed."
}
