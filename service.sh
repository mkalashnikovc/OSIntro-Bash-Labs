#!/bin/bash
set -euo pipefail

PID_FILE="/tmp/myservice.pid"

is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

service_start() {
    if is_running; then
        local pid
        pid=$(cat "$PID_FILE")
        echo "Already running (PID $pid)"
        exit 0
    fi

    sleep 3600 &
    local bg_pid=$!
    echo "$bg_pid" > "$PID_FILE"
    echo "Started (PID $bg_pid)"
}

service_stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "Service not running"
        exit 0
    fi

    local pid
    pid=$(cat "$PID_FILE")

    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null || true
        rm -f "$PID_FILE"
        echo "Stoped (PID $pid)"
    else
        rm -f "$PID_FILE"
        echo "No such process (PID $pid)."
    fi
}

service_status() {
    if is_running; then
        local pid
        pid=$(cat "$PID_FILE")
        echo "Running (PID $pid)"
    else
        echo "Not running"
    fi
}

service_help() {
    echo "Usage: $0 {start|stop|status|help}"
}

COMMAND="${1:-help}"

case "$COMMAND" in
    start)
        service_start
        ;;
    stop)
        service_stop
        ;;
    status)
        service_status
        ;;
    help)
        service_help
        ;;
    *)
        echo "ERROR: Unknown command '$COMMAND'" >&2
        service_help >&2
        exit 1
        ;;
esac
