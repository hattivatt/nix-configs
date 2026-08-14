#!/bin/bash

# Конфигурация
WORK_TIME=30
REST_TIME_SHORT=5
REST_TIME_LONG=10
NOTIFICATION_DELAY=5
PIPE="/tmp/pomodoro_fifo"
APP_NAME="Pomodoro"
ICON="alarm-clock"

# Создание FIFO
[ -p "$PIPE" ] || mkfifo "$PIPE"
# Магия: открываем FIFO для чтения/записи на дескрипторе 3, чтобы скрипт не блокировался
exec 3<>"$PIPE"

send_notif() {
    notify-send -a "$APP_NAME" -i "$ICON" "$1"
    sleep "$NOTIFICATION_DELAY"
    swaync-client --close-latest
}

if [[ "$1" == "toggle-pause" ]]; then
    echo "toggle" > "$PIPE"
    exit 0
fi

paused=false

run_timer() {
    local remaining=$1
    local mode=$2

    while [ "$remaining" -gt 0 ]; do
        # Читаем команду из дескриптора 3 (таймаут 1 сек)
        if read -t -r 1 cmd <&3; then
            if [[ "$cmd" == "toggle" ]]; then
                if [ "$paused" == "true" ]; then
                    paused=false
                    [ "$mode" == "work" ] && { swaync-client -dn; playerctl -p spotify play; }
                    send_notif "Resumed"
                else
                    paused=true
                    [ "$mode" == "work" ] && { swaync-client -df; playerctl -p spotify pause; }
                    send_notif "Paused"
                fi
            fi
        fi

        if [ "$paused" == "false" ]; then
            ((remaining--))
        fi
    done
}

counter=1

while true; do
    # --- РАБОТА ---
    playerctl play
    send_notif "Work started (Session $counter)"
    swaync-client -dn

    run_timer $((WORK_TIME * 60)) "work"

    # --- ПЕРЕХОД К ОТДЫХУ ---
    swaync-client -df
    playerctl pause

    if ((counter % 2 == 0)); then
        current_rest=$REST_TIME_LONG
        msg="Long rest time: $current_rest min"
    else
        current_rest=$REST_TIME_SHORT
        msg="Short rest time: $current_rest min"
    fi
    send_notif "$msg"

    # --- ОТДЫХ ---
    run_timer $((current_rest * 60)) "rest"

    ((counter++))
done
