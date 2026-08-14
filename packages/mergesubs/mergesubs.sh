#!/usr/bin/env bash

export LANG=C.UTF-8

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Директория для бэкапов
BKP_DIR="bkp"

# Язык субтитров по умолчанию
SUB_LANG="rus"

# Проверка зависимостей
command -v mkvmerge >/dev/null 2>&1 || { log_error "mkvmerge не найден"; exit 1; }

# Создаём директорию для бэкапов
mkdir -p "$BKP_DIR"

log_info "Ищем субтитры и видео файлы..."

# Ищем все субтитры
mapfile -t subs < <(find . -maxdepth 1 -type f \( -iname "*.ass" -o -iname "*.ssa" -o -iname "*.srt" \) | sort)

if [[ ${#subs[@]} -eq 0 ]]; then
    log_warn "Субтитры не найдены"
    exit 0
fi

log_info "Найдено ${#subs[@]} субтитров"

# Собираем пары субтитр-видео
declare -A pairs
avi_files=()

for sub in "${subs[@]}"; do
    sub_name=$(basename "$sub")
    sub_basename="${sub_name%.*}"

    # Ищем соответствующий видеофайл
    video=""
    for ext in mkv avi; do
        candidate="./${sub_basename}.${ext}"
        if [[ -f "$candidate" ]]; then
            video="$candidate"
            break
        fi
    done

    if [[ -z "$video" ]]; then
        log_warn "Видеофайл не найден для: $sub_name"
        continue
    fi

    pairs["$sub"]="$video"

    # Запоминаем AVI файлы
    if [[ "$video" =~ \.avi$ ]]; then
        avi_files+=("$video")
    fi
done

pair_count=${#pairs[@]}

if [[ $pair_count -eq 0 ]]; then
    log_warn "Пары субтитры-видео не найдены"
    exit 0
fi

log_info "Найдено $pair_count пар"

# Переменные для хранения метаданных AVI
declare -A track_langs_by_idx  # idx => lang
declare -A track_names_by_idx  # idx => name
skip_avi_meta=true

if [[ ${#avi_files[@]} -gt 0 ]]; then
    first_avi="${avi_files[0]}"
    log_step "Обнаружен AVI файл: $(basename "$first_avi")"

    if ! command -v mediainfo >/dev/null 2>&1; then
        log_warn "mediainfo не найден — пропуск анализа дорожек"
    else
        avi_info=$(mediainfo --Output=JSON "$first_avi" 2>/dev/null)
        if [[ -z "$avi_info" ]]; then
            log_warn "Не удалось получить информацию о дорожках через mediainfo"
        else
            skip_avi_meta=false
            log_info "Настройка языковых атрибутов для дорожек AVI:"
            echo ""

            # Получаем массив всех дорожек
            mapfile -t tracks < <(echo "$avi_info" | jq -c '.media.track[]')

            output_track_index=0  # В видеофайле Video всегда 0, дальше Audio/Subtitles

            for track_json in "${tracks[@]}"; do
                type=$(echo "$track_json" | jq -r '.["@type"] // empty')
                [[ -z "$type" || "$type" == "General" || "$type" == "Video" ]] && continue
                [[ "$type" != "Audio" && "$type" != "Text" ]] && continue

                codec=$(echo "$track_json" | jq -r '.Format // "?"')
                lang_raw=$(echo "$track_json" | jq -r '.Language // "Unknown"')
                title=$(echo "$track_json" | jq -r '.Title // empty')

                # Автоопределение языка (трёхбуквенный код)
                if [[ "$lang_raw" =~ ^[a-zA-Z]{3,}$ ]]; then
                    default_lang=$(echo "$lang_raw" | cut -c-3 | tr '[:upper:]' '[:lower:]')
                else
                    default_lang="---"
                fi

                echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
                echo -e "${CYAN}Дорожка #$output_track_index ($type)${NC}"
                echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
                echo -e "  ${GREEN}Кодек:${NC}     $codec"
                if [[ -n "$title" && "$title" != "null" ]]; then
                    echo -e "  ${GREEN}Заголовок:${NC} $title"
                fi
                echo -e "  ${GREEN}Язык:${NC}      $default_lang"

                while true; do
                    read -p -r "  Установить язык (3 буквы, напр., jpn): [$default_lang] " user_lang
                    user_lang=${user_lang:-$default_lang}
                    if [[ "$user_lang" =~ ^[a-z]{3}$|^\-\-\-$ ]]; then
                        break
                    fi
                    log_warn "Введите 3 строчные буквы или ---"
                done

                read -p -r "  Имя дорожки [Enter - без имени]: " user_name

                track_langs_by_idx["$output_track_index"]="$user_lang"
                [[ -n "$user_name" ]] && track_names_by_idx["$output_track_index"]="$user_name"

                ((output_track_index++))
            done

            if ((output_track_index > 0)); then
                log_info "Настроено метаданных для $output_track_index дорожек"
            fi
        fi
    fi
fi

# Переносим оригиналы в bkp
declare -A bkp_pairs

log_step "Перемещаю файлы в $BKP_DIR..."

for sub in "${!pairs[@]}"; do
    video="${pairs[$sub]}"
    sub_name=$(basename "$sub")
    video_name=$(basename "$video")

    mv "$sub" "${BKP_DIR}/${sub_name}"
    mv "$video" "${BKP_DIR}/${video_name}"

    bkp_pairs["${BKP_DIR}/${sub_name}"]="${BKP_DIR}/${video_name}"
done

log_info "Перенесено $pair_count пар"

# Обрабатываем
log_step "Выполняю мержинг..."
processed=0
errors=0

# Преобразуем в отсортированный список
mapfile -t sub_list < <(printf '%s\n' "${!bkp_pairs[@]}" | sort)

for sub_bkp in "${sub_list[@]}"; do
    video_bkp="${bkp_pairs[$sub_bkp]}"
    video_name=$(basename "$video_bkp")
    video_basename="${video_name%.*}"
    ext="${video_bkp##*.}"
    sub_name=$(basename "$sub_bkp")
    charset="UTF-8"

    case "${sub_name##*.}" in
        srt|txt) charset="UTF-8" ;;
        ass|ssa) charset="UTF-8" ;;  # ASS/SSA обычно UTF-8
        *)       charset="Windows-1251" ;;  # Fallback для старых SRT
    esac

    output="./${video_basename}.mkv"
    args=("-o" "$output" "$video_bkp")

    # Назначаем метаданные для существующих дорожек (если это AVI и есть данные)
    if [[ "$ext" == "avi" ]] && [[ "$skip_avi_meta" == false ]]; then
        for idx in "${!track_langs_by_idx[@]}"; do
            lang="${track_langs_by_idx[$idx]}"
            args+=("--language" "$idx:$lang")
            if [[ -n "${track_names_by_idx[$idx]}" ]]; then
                name="${track_names_by_idx[$idx]}"
                args+=("--track-name" "$idx:$name")
            fi
        done
    fi

    # Добавляем субтитры как новую дорожку (авто-назначение следующего номера)
    args+=(
        "--language" "0:$SUB_LANG"
        "--sub-charset" "0:$charset"
        "$sub_bkp"
    )

    processed=$((processed + 1))
    log_info "[$processed/$pair_count] $video_name + $sub_name"

    if ! mkvmerge "${args[@]}" >>mkvmerge.log 2>&1; then
        log_error "Ошибка при обработке: $video_name + $sub_name"
        errors=$((errors + 1))
    fi
done

echo ""
log_info "Готово: $processed успешно, ошибок: $errors"
log_info "Лог mkvmerge сохранён в mkvmerge.log"
log_info "Бэкап исходников: ./$BKP_DIR/"
