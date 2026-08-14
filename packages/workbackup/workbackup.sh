#!/bin/bash

# Проверка количества аргументов
if [ "$#" -ne 2 ]; then
    echo "Использование: $0 <исходный_файл> <каталог_бэкапа>"
    exit 1
fi

SOURCE_FILE="$1"
BACKUP_DIR="$2"

# Проверка существования исходного файла
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Ошибка: Исходный файл '$SOURCE_FILE' не существует"
    exit 1
fi

# Проверка существования каталога бэкапа
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Ошибка: Каталог бэкапа '$BACKUP_DIR' не существует"
    exit 1
fi

# Имя файла без пути
FILENAME=$(basename "$SOURCE_FILE")
NAME="${FILENAME%.*}"
EXT="${FILENAME##*.}"

# Добавляем дату в формате DDMMYYYY
DATE=$(date +"%d%m%Y")
BACKUP_NAME="${NAME}-${DATE}.${EXT}"

# Создание бэкапа с помощью rsync
if ! rsync -av --progress "$SOURCE_FILE" "${BACKUP_DIR}/${BACKUP_NAME}"; then
    echo "Ошибка при копировании файла" >&2
    exit 1
fi

# Удаление старых бэкапов, оставляя только последние 2
mapfile -t _old_backups < <(
  find "${BACKUP_DIR}" -maxdepth 1 -type f -name "${NAME}-*.${EXT}" -printf '%T@\t%p\n' \
    2>/dev/null | sort -nr | tail -n +3 | cut -f2-
)
if ((${#_old_backups[@]} > 0)); then
  rm -f "${_old_backups[@]}"
fi

echo "Бэкап успешно создан: ${BACKUP_DIR}/${BACKUP_NAME}"
