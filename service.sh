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
        echo "Уже запущен (PID $pid)"
        exit 0
    fi

    sleep 3600 &
    local bg_pid=$!
    echo "$bg_pid" > "$PID_FILE"
    echo "Запущен (PID $bg_pid)"
}

service_stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "Сервис не запущен"
        exit 0
    fi

    local pid
    pid=$(cat "$PID_FILE")

    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null || true
        rm -f "$PID_FILE"
        echo "Остановлен (PID $pid)"
    else
        rm -f "$PID_FILE"
        echo "Процесс (PID $pid) не существует. PID-файл удален."
    fi
}

service_status() {
    if is_running; then
        local pid
        pid=$(cat "$PID_FILE")
        echo "Работает (PID $pid)"
    else
        echo "Не работает"
    fi
}

service_help() {
    echo "Использование: $0 {start|stop|status|help}"
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
        echo "Ошибка: Неизвестная команда '$COMMAND'" >&2
        service_help >&2
        exit 1
        ;;
esac
