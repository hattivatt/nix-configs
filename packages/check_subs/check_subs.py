# !/usr/bin/env python3
import sys
from pathlib import Path

# Настройки
GAP_THRESHOLD = 300
LONG_DURATION_THRESHOLD = 30
SUPPORTED_EXT = {'.srt', '.ass'}

# ANSI стили
BOLD = '\033[1m'
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
NC = '\033[0m'


def parse_time_srt(time_str):
    try:
        h, m, s = time_str.split(':')
        s, ms = s.split(',')
        return int(h) * 3600 + int(m) * 60 + int(s) + float(ms) / 1000
    except Exception:
        return None


def parse_time_ass(time_str):
    try:
        h, m, s = time_str.split(':')
        s, cs = s.split('.')
        return int(h) * 3600 + int(m) * 60 + int(s) + int(cs) * 0.01
    except Exception:
        return None


def extract_srt_entries(file_path):
    """Возвращает список (index, start, end, text, raw_time_line) для srt"""
    entries = []
    try:
        with open(
            file_path, 'r', encoding='utf-8-sig', errors='ignore'
        ) as f:
            content = f.read()
    except Exception as e:
        print(f"❌ Ошибка чтения {file_path}: {e}")
        return entries

    content = content.replace('\r\n', '\n').replace('\r', '\n')
    blocks = content.strip().split('\n\n')

    for block in blocks:
        lines = block.split('\n')
        if len(lines) < 2:
            continue

        first_line = lines[0].strip()
        if not first_line.isdigit():
            continue

        try:
            idx = int(first_line)
        except Exception:
            continue

        if '-->' not in lines[1]:
            continue

        time_line = lines[1].strip()
        try:
            start_str, end_str = [
                x.strip() for x in time_line.split('-->')
            ]
            start = parse_time_srt(start_str)
            end = parse_time_srt(end_str)
            if start is None or end is None:
                continue
        except Exception:
            continue

        text = '\n'.join(lines[2:]) if len(lines) > 2 else ''
        entries.append((idx, start, end, text, time_line))

    return entries


def extract_ass_entries(file_path):
    """Возвращает список (index, start, end, text, raw_line) для ass"""
    entries = []
    in_events = False
    format_fields = {}
    counter = 0

    try:
        with open(
            file_path, 'r', encoding='utf-8-sig', errors='ignore'
        ) as f:
            for line in f:
                line_stripped = line.strip()

                if line_stripped == '[Events]':
                    in_events = True
                    continue

                if not in_events:
                    continue

                if line_stripped.startswith('Format:'):
                    headers = [
                        h.strip() for h in line_stripped[7:].split(',')
                    ]
                    try:
                        format_fields = {
                            'Start': headers.index('Start'),
                            'End': headers.index('End'),
                            'Text': headers.index('Text')
                        }
                    except Exception:
                        pass
                    continue

                if line_stripped.startswith('Dialogue:'):
                    if not format_fields:
                        continue
                    try:
                        parts = line_stripped[9:].split(
                            ',', format_fields['Text']
                        )
                        start_str = parts[
                            format_fields['Start']
                        ].strip()
                        end_str = parts[
                            format_fields['End']
                        ].strip()
                        text = ','.join(
                            parts[format_fields['Text']:]
                        ).strip()

                        start = parse_time_ass(start_str)
                        end = parse_time_ass(end_str)
                        if start is None or end is None:
                            continue

                        counter += 1
                        entries.append(
                            (counter, start, end, text, line_stripped)
                        )
                    except Exception:
                        pass
    except Exception as e:
        print(f"❌ Ошибка чтения {file_path}: {e}")

    return entries


def find_reference_files(target_path, target_entries):
    """Ищет файлы-эталоны в той же папке с похожим количеством строк (±10)"""
    folder = target_path.parent
    target_count = len(target_entries)

    candidates = []
    for ext in SUPPORTED_EXT:
        for f in folder.glob(f'*{ext}'):
            if f.name == target_path.name:
                continue

            if ext == '.srt':
                ref_entries = extract_srt_entries(f)
            else:
                ref_entries = extract_ass_entries(f)

            if not ref_entries:
                continue

            ref_count = len(ref_entries)
            if abs(ref_count - target_count) <= 10:
                candidates.append((f, ref_entries, ref_count))

    return candidates


def compare_with_reference(
    target_entries, ref_entries, target_name, ref_name
):
    """Сравнивает два файла и возвращает список расхождений"""
    issues = []

    if len(target_entries) != len(ref_entries):
        issues.append(
            f"Разное количество блоков: "
            f"{len(target_entries)} vs {len(ref_entries)}"
        )

    min_len = min(len(target_entries), len(ref_entries))

    for i in range(min_len):
        t_idx, t_start, t_end, t_text, t_raw = target_entries[i]
        r_idx, r_start, r_end, r_text, r_raw = ref_entries[i]

        if t_idx != r_idx:
            issues.append(
                f"Запись {i + 1}: нумерация в файле={t_idx}, "
                f"в эталоне={r_idx}"
            )

        start_diff = abs(t_start - r_start)
        end_diff = abs(t_end - r_end)

        if start_diff > 0.1 or end_diff > 0.1:
            issues.append(
                f"Запись {i + 1} (файл #{t_idx}): "
                f"тайминги расходятся"
            )
            issues.append(
                f"  Эталон:  {format_time(r_start)} --> "
                f"{format_time(r_end)}"
            )
            issues.append(
                f"  Файл:    {format_time(t_start)} --> "
                f"{format_time(t_end)}"
            )
            if start_diff > 0.1:
                issues.append(
                    f"  Разница начала: {start_diff:.3f} сек"
                )
            if end_diff > 0.1:
                issues.append(
                    f"  Разница конца: {end_diff:.3f} сек"
                )

    return issues


def format_time(seconds):
    """Форматирует секунды в HH:MM:SS.mmm"""
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = seconds % 60
    return f"{h:02d}:{m:02d}:{s:06.3f}".replace('.', ',')


def apply_reference_fix(target_path, target_entries, ref_entries):
    """Применяет тайминги и нумерацию из эталона к целевому файлу"""
    ext = target_path.suffix.lower()

    if ext == '.srt':
        new_lines = []

        for i in range(len(target_entries)):
            if i < len(ref_entries):
                new_idx = ref_entries[i][0]
                new_start = ref_entries[i][1]
                new_end = ref_entries[i][2]
            else:
                new_idx = i + 1
                new_start = target_entries[i][1]
                new_end = target_entries[i][2]

            text = target_entries[i][3]

            new_lines.append(str(new_idx))
            new_lines.append(
                f"{format_time(new_start)} --> "
                f"{format_time(new_end)}"
            )
            if text:
                new_lines.append(text)
            new_lines.append('')

        try:
            with open(target_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(new_lines) + '\n')
            return True
        except Exception as e:
            print(f"❌ Ошибка записи: {e}")
            return False

    elif ext == '.ass':
        try:
            with open(
                target_path, 'r',
                encoding='utf-8-sig', errors='ignore'
            ) as f:
                lines = f.readlines()

            dialogue_idx = 0
            new_lines = []

            for line in lines:
                if line.strip().startswith('Dialogue:'):
                    if dialogue_idx < len(ref_entries):
                        old_line = line.strip()
                        parts = old_line.split(',', 9)
                        if len(parts) >= 3:
                            new_start = format_time(
                                ref_entries[dialogue_idx][1]
                            ).replace(',', '.')
                            new_end = format_time(
                                ref_entries[dialogue_idx][2]
                            ).replace(',', '.')
                            parts[1] = new_start
                            parts[2] = new_end
                            new_line = ','.join(parts) + '\n'
                            new_lines.append(new_line)
                        else:
                            new_lines.append(line)
                        dialogue_idx += 1
                    else:
                        new_lines.append(line)
                else:
                    new_lines.append(line)

            with open(target_path, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            return True
        except Exception as e:
            print(f"❌ Ошибка записи: {e}")
            return False

    return False


def check_standard(file_path, entries):
    """Стандартная проверка (если эталон не найден)"""
    ext = file_path.suffix.lower()
    issues_found = 0

    print(f"\n📄 {BOLD}Стандартная проверка:{NC} {file_path.name}\n")

    for i, (idx, start, end, text, raw) in enumerate(entries):
        duration = end - start
        if duration >= LONG_DURATION_THRESHOLD:
            start_h = int(start // 3600)
            end_h = int(end // 3600)

            if abs(end_h - start_h) >= 1 and duration <= 7200:
                print(
                    f"⚠️  {YELLOW}Длинная реплика "
                    f"(ошибка в часах?){NC} блок #{idx}"
                )
                print(f"   {format_time(start)} --> {format_time(end)}")
                print(f"   Длительность: {duration:.1f} сек")
                print()
                issues_found += 1
            else:
                print(
                    f"⚠️  Длинная реплика ({duration:.1f} сек): "
                    f"блок #{idx}"
                )
                print()
                issues_found += 1

    if ext == '.srt':
        for i in range(len(entries) - 1):
            curr_idx, curr_start, curr_end, curr_text, curr_raw = (
                entries[i]
            )
            next_idx, next_start, next_end, next_text, next_raw = (
                entries[i + 1]
            )

            if curr_end > next_start:
                print(
                    f"🔴 {RED}Перекрытие{NC}: "
                    f"блоки #{curr_idx} и #{next_idx}"
                )
                print(f"   Конец первой: {format_time(curr_end)}")
                print(f"   Начало второй: {format_time(next_start)}")
                print()
                issues_found += 1

            gap = next_start - curr_end
            if gap >= GAP_THRESHOLD:
                print(
                    f"❌ {RED}Большой промежуток{NC} ({gap:.1f} сек)"
                )
                print(f"   Между блоками #{curr_idx} и #{next_idx}")
                print()
                issues_found += 1

            if next_idx != curr_idx + 1:
                print(
                    f"🔴 {RED}Сбой нумерации{NC}: после {curr_idx} "
                    f"идёт {next_idx} (ожидался {curr_idx + 1})"
                )
                print()
                issues_found += 1

    if issues_found == 0:
        print(f"{GREEN}✅ Проблем не обнаружено{NC}\n")

    return issues_found


def process_single_file(file_path):
    """Обработка одного файла с приоритетом сверки с эталоном"""
    file_path = Path(file_path).resolve()

    if not file_path.exists():
        print(f"❌ Файл не существует: {file_path}")
        return 1

    ext = file_path.suffix.lower()
    if ext not in SUPPORTED_EXT:
        print(f"❌ Неподдерживаемый формат: {ext}")
        return 1

    if ext == '.srt':
        entries = extract_srt_entries(file_path)
    else:
        entries = extract_ass_entries(file_path)

    if not entries:
        print(
            "⚠️  Не удалось распарсить файл или файл пуст: "
            f"{file_path.name}"
        )
        return 0

    print(f"\n{BOLD}📁 Файл:{NC} {file_path.name}")
    print(f"📊 Блоков: {len(entries)}")

    print("\n🔍 Поиск эталонных файлов...")
    candidates = find_reference_files(file_path, entries)

    if candidates:
        print(f"✅ Найдено {len(candidates)} подходящих файл(ов):\n")

        for i, (f, ref_entries, count) in enumerate(candidates, 1):
            print(f"  {i}. {BOLD}{f.name}{NC} ({count} блоков)")

        print(f"\n  0. {BOLD}Пропустить{NC} (стандартная проверка)")

        try:
            choice = input(
                "\nВыберите эталон для сверки: "
            ).strip()
            choice = int(choice)

            if choice == 0:
                print("\n" + "=" * 50)
                return check_standard(file_path, entries)
            elif 1 <= choice <= len(candidates):
                ref_file, ref_entries, _ = candidates[choice - 1]

                print(
                    f"\n{BOLD}🔍 Сверка с {ref_file.name}:{NC}\n"
                )

                issues = compare_with_reference(
                    entries, ref_entries,
                    file_path.name, ref_file.name
                )

                if not issues:
                    print(f"{GREEN}✅ Расхождений не найдено{NC}")
                    print("   Файл соответствует эталону.\n")
                    return 0

                print(f"{YELLOW}⚠️  Обнаружены расхождения:{NC}\n")
                for issue in issues:
                    print(f"  • {issue}")
                print()

                confirm = input(
                    f"Привести в соответствие с {BOLD}{ref_file.name}"
                    f"{NC}? [y/N]: "
                ).strip().lower()

                if confirm == 'y':
                    if apply_reference_fix(
                        file_path, entries, ref_entries
                    ):
                        print(f"\n{GREEN}✅ Файл исправлен{NC}\n")
                    else:
                        print(f"\n{RED}❌ Не удалось исправить файл{NC}\n")
                else:
                    print("\n" + "=" * 50)
                    return check_standard(file_path, entries)
            else:
                print("\n" + "=" * 50)
                return check_standard(file_path, entries)

        except ValueError:
            print("\n" + "=" * 50)
            return check_standard(file_path, entries)
    else:
        print("⚠️  Подходящих эталонов не найдено (ищем ±10 блоков)")
        print("\n" + "=" * 50)
        return check_standard(file_path, entries)


def process_folder(folder_path):
    """Обработка папки (старая логика)"""
    folder = Path(folder_path).resolve()

    if not folder.is_dir():
        print(f"❌ Не является папкой: {folder}")
        return 1

    files = []
    for ext in SUPPORTED_EXT:
        files.extend(folder.rglob(f'*{ext}'))
    files = sorted(set(files))

    if not files:
        print(f"🔍 Нет файлов субтитров в {folder}")
        return 0

    print(f"📎 Найдено {len(files)} файлов\n")

    total_issues = 0
    for file_path in files:
        ext = file_path.suffix.lower()
        if ext == '.srt':
            entries = extract_srt_entries(file_path)
        else:
            entries = extract_ass_entries(file_path)

        if entries:
            total_issues += check_standard(file_path, entries)

    print(f"\n{BOLD}✅ Готово.{NC} Всего проблем: {total_issues}")
    return total_issues


def main():
    if len(sys.argv) > 1:
        path = Path(sys.argv[1])

        if path.is_file():
            return process_single_file(path)
        else:
            return process_folder(path)
    else:
        return process_folder(".")


if __name__ == '__main__':
    sys.exit(main())
