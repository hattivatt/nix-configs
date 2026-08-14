#!/bin/bash

set -euo pipefail

if ! command -v fuzzel &> /dev/null; then
    echo "Ошибка: fuzzel не установлен."
    exit 1
fi

wifi_connect() {
    if ! command -v nmcli &> /dev/null; then
        echo "Ошибка: nmcli не установлен."
        exit 1
    fi

    # Получаем multiline вывод с принудительным сканированием
    local networks_raw
    networks_raw=$(nmcli -f ssid,signal,security,bssid -m multiline device wifi list --rescan yes 2>/dev/null)

    if [ -z "$networks_raw" ]; then
        echo "Нет доступных Wi-Fi сетей"
        exit 1
    fi

    # Парсим multiline вывод и сохраняем только лучший сигнал для каждого SSID
    # Каждая сеть: SSID, SIGNAL, SECURITY, BSSID (идут подряд без разделителей)
    local tmpfile
    tmpfile=$(mktemp)

    # Используем временные файлы для хранения данных о сетях
    local networks_tmp
    networks_tmp=$(mktemp)

    local ssid="" signal="" security="" bssid=""

    while IFS= read -r line; do
        # Определяем тип строки и извлекаем значение
        if [[ "$line" =~ ^SSID:[[:space:]]*(.*)$ ]]; then
            # Новая сеть - сначала сохраняем предыдущую если есть
            if [ -n "$bssid" ]; then
                # Пропускаем сети с SSID "--" (невалидные)
                if [ "$ssid" != "--" ]; then
                    # Используем SSID как ключ, сохраняем только если сигнал лучше
                    local key="$ssid"
                    [ -z "$key" ] && key="<скрытая>_$bssid"  # Для скрытых сетей используем BSSID как часть ключа
                    echo "${key}|${signal}|${security}|${bssid}|${ssid}" >> "$networks_tmp"
                fi
            fi
            ssid="${BASH_REMATCH[1]}"
            signal=""
            security=""
            bssid=""
        elif [[ "$line" =~ ^SIGNAL:[[:space:]]*([0-9]+) ]]; then
            signal="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^SECURITY:[[:space:]]*(.*)$ ]]; then
            security="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^BSSID:[[:space:]]*([0-9A-Fa-f:]{17}) ]]; then
            bssid="${BASH_REMATCH[1]}"
        fi
    done <<< "$networks_raw"

    # Сохраняем последнюю сеть
    if [ -n "$bssid" ] && [ "$ssid" != "--" ]; then
        local key="$ssid"
        [ -z "$key" ] && key="<скрытая>_$bssid"
        echo "${key}|${signal}|${security}|${bssid}|${ssid}" >> "$networks_tmp"
    fi

    # Выбираем только сети с лучшим сигналом для каждого SSID и сортируем по сигналу
    local best_networks
    best_networks=$(sort -t'|' -k1,1 -k2,2nr "$networks_tmp" | awk -F'|' '
        !seen[$1]++ {
            signal=$2
            security=$3
            bssid=$4
            ssid=$5
            if (ssid == "") {
                display="<скрытая сеть> (сигнал: " signal "%) " security
            } else {
                display=ssid " (сигнал: " signal "%) " security
            }
            # Выводим сигнал первым для сортировки
            print signal "\t" display "\t" ssid "\t" bssid
        }
    ' | sort -t$'\t' -k1,1nr | cut -f2-)

    echo "$best_networks" > "$tmpfile"
    rm -f "$networks_tmp"

    if [ ! -s "$tmpfile" ]; then
        echo "Нет доступных сетей"
        rm -f "$tmpfile"
        exit 0
    fi

    # Получаем активное подключение
    local active_bssid
    active_bssid=$(nmcli -t --escape no -f active,bssid connection show --active 2>/dev/null | grep '^yes:' | cut -d: -f2- | head -1 || true)

    if [ -n "$active_bssid" ]; then
        echo "Текущая сеть: $active_bssid"
        # Убираем текущую сеть
        grep -vF "${active_bssid}$" "$tmpfile" > "${tmpfile}.tmp" || true
        mv "${tmpfile}.tmp" "$tmpfile"
    fi

    if [ ! -s "$tmpfile" ]; then
        echo "Нет других доступных сетей"
        rm -f "$tmpfile"
        exit 0
    fi

    # Выбираем через fuzzel
    local selected
    selected=$(fuzzel --dmenu -p "Wi-Fi: " --with-nth=1 < "$tmpfile")

    if [ -z "$selected" ]; then
        echo "Сеть не выбрана"
        rm -f "$tmpfile"
        exit 0
    fi

    # Извлекаем SSID и BSSID
    local chosen_ssid chosen_bssid
    chosen_ssid=$(printf '%s' "$selected" | cut -d$'\t' -f2)
    chosen_bssid=$(printf '%s' "$selected" | cut -d$'\t' -f3)

    rm -f "$tmpfile"

    echo "Подключение к: ${chosen_ssid:-<скрытая сеть>}"
    if [ -z "$chosen_ssid" ]; then
        nmcli device wifi connect "$chosen_bssid"
    else
        nmcli device wifi connect "$chosen_ssid"
    fi
}

unmount_device() {
    local selected device_path

    if command -v udiskie-info &> /dev/null; then
        # Получаем все устройства и фильтруем только смонтированные
        # udiskie-info выводит \t как литералы, используем другой разделитель
        local all_devices tmpfile
        all_devices=$(udiskie-info --all --output "{device_file}|{id_label}|{mount_path}" 2>/dev/null || true)

        tmpfile=$(mktemp)

        # Фильтруем только смонтированные (mount_path не пустой) и пишем во временный файл
        while IFS='|' read -r dev label mount_path; do
            # Пропускаем если mount_path пустой (не смонтировано)
            [ -z "$mount_path" ] && continue
            # Форматируем для отображения
            label="${label:-Без метки}"
            echo "${dev}: ${label} (${mount_path})" >> "$tmpfile"
        done <<< "$all_devices"

        if [ ! -s "$tmpfile" ]; then
            echo "Нет смонтированных устройств"
            rm -f "$tmpfile"
            exit 0
        fi

        selected=$(fuzzel --dmenu -p "Отмонтировать: " < "$tmpfile")

        if [ -z "$selected" ]; then
            echo "Устройство не выбрано"
            rm -f "$tmpfile"
            exit 0
        fi

        device_path=$(echo "$selected" | cut -d':' -f1)
        rm -f "$tmpfile"
        echo "Отмонтирование: $device_path"
        udiskie-umount "$device_path"

    elif command -v udisksctl &> /dev/null; then
        # Получаем все блочные устройства
        local all_devices tmpfile
        all_devices=$(udisksctl dump 2>/dev/null | grep "^/org/freedesktop/UDisks2/block_devices/" | sed 's/://g' || true)

        tmpfile=$(mktemp)

        # Фильтруем только смонтированные и пишем во временный файл
        while IFS= read -r device; do
            local dev_name label mount_path device_info
            dev_name=$(basename "$device")

            # Получаем информацию об устройстве
            device_info=$(udisksctl info --block-device "/dev/$dev_name" 2>/dev/null || true)

            # Извлекаем mount_path
            mount_path=$(echo "$device_info" | grep "MountPoints:" | awk -F': ' '{print $2}' || echo "")

            # Пропускаем если не смонтировано
            [ -z "$mount_path" ] && continue

            # Извлекаем метку
            label=$(echo "$device_info" | grep "IdLabel:" | awk -F': ' '{print $2}' || echo "")
            label="${label:-Без метки}"

            echo "/dev/$dev_name: $label ($mount_path)" >> "$tmpfile"
        done <<< "$all_devices"

        if [ ! -s "$tmpfile" ]; then
            echo "Нет смонтированных устройств"
            rm -f "$tmpfile"
            exit 0
        fi

        selected=$(fuzzel --dmenu -p "Отмонтировать: " < "$tmpfile")

        if [ -z "$selected" ]; then
            echo "Устройство не выбрано"
            rm -f "$tmpfile"
            exit 0
        fi

        device_path=$(echo "$selected" | cut -d':' -f1)
        rm -f "$tmpfile"
        echo "Отмонтирование: $device_path"
        udisksctl unmount --block-device "$device_path"

    else
        echo "Ошибка: Не найден udiskie-info или udisksctl."
        exit 1
    fi
}

# Функция для работы с Bluetooth устройствами
bluetooth_manage() {
    if ! command -v bluetoothctl &> /dev/null; then
        echo "Ошибка: bluetoothctl не установлен."
        exit 1
    fi

    # Получаем список спаренных устройств через stdin (bluetoothctl требует инициализации)
    local devices_raw
    devices_raw=$(echo "devices" | bluetoothctl --timeout 5 2>/dev/null | grep "^Device" || true)

    if [ -z "$devices_raw" ]; then
        echo "Нет спаренных Bluetooth устройств"
        exit 0
    fi

    local tmpfile
    tmpfile=$(mktemp)

    # Для каждого устройства получаем информацию и статус
    while IFS= read -r line; do
        local mac name connected
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)

        # Получаем статус подключения
        local info
        info=$(echo "info $mac" | bluetoothctl --timeout 2 2>/dev/null || true)

        if echo "$info" | grep -q "Connected: yes"; then
            connected="подключено"
        else
            connected="отключено"
        fi

        # Форматируем: имя (статус) <tab> mac <tab> connected
        printf '%s (%s)\t%s\t%s\n' "$name" "$connected" "$mac" "$connected" >> "$tmpfile"
    done <<< "$devices_raw"

    if [ ! -s "$tmpfile" ]; then
        echo "Не удалось получить информацию об устройствах"
        rm -f "$tmpfile"
        exit 1
    fi

    # Сортируем: сначала подключённые, потом по имени
    sort -t$'\t' -k3,3r -k1,1 "$tmpfile" -o "$tmpfile"

    # Выбираем через fuzzel
    local selected
    selected=$(fuzzel --dmenu -p "Bluetooth: " < "$tmpfile")

    if [ -z "$selected" ]; then
        echo "Устройство не выбрано"
        rm -f "$tmpfile"
        exit 0
    fi

    # Извлекаем MAC и статус
    local chosen_mac chosen_status
    chosen_mac=$(printf '%s' "$selected" | cut -d$'\t' -f2)
    chosen_status=$(printf '%s' "$selected" | cut -d$'\t' -f3)

    rm -f "$tmpfile"

    if [ "$chosen_status" = "подключено" ]; then
        echo "Отключение: $chosen_mac"
        echo "disconnect $chosen_mac" | bluetoothctl --timeout 5 2>/dev/null
    else
        echo "Подключение: $chosen_mac"
        echo "connect $chosen_mac" | bluetoothctl --timeout 5 2>/dev/null
    fi
}

show_help() {
    cat << EOF
Использование: $0 <команда>

Команды:
    wifi, w         Подключиться к Wi-Fi сети (через nmcli)
    unmount, u      Отмонтировать устройство (через udiskie-info/udisksctl)
    bluetooth, bt   Управление Bluetooth устройствами (через bluetoothctl)
    help, h         Показать эту справку
EOF
}

case "${1:-}" in
    wifi|w)
        wifi_connect
        ;;
    unmount|umount|u)
        unmount_device
        ;;
    bluetooth|bt)
        bluetooth_manage
        ;;
    help|h|--help|-h)
        show_help
        ;;
    *)
        echo "Неизвестная команда: ${1:-}"
        show_help
        exit 1
        ;;
esac
