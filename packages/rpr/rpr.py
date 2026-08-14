# !/usr/bin/env python3

import pyperclip


def get_task_status(is_yesterday=True):
    """Получить статус задачи с выбором из предопределенных вариантов"""
    if is_yesterday:
        statuses = [
            "began working on this task",
            "kept working on this task",
            "finished this task",
        ]
    else:
        statuses = [
            "begin working on this task",
            "keep working on this task",
            "finish this task",
        ]

    print("\nВыберите статус:")
    for i, status in enumerate(statuses, 1):
        print(f"{i}. {status}")
    print("4. Custom (ввести вручную)")
    print("0. No status (пропустить)")

    while True:
        try:
            choice = input("Введите номер статуса (0-4): ").strip()
            if choice == "1" or choice == "2" or choice == "3":
                return statuses[int(choice) - 1]
            elif choice == "4":
                return input("Введите кастомный статус: ").strip()
            elif choice == "0":
                return None
            else:
                print("Пожалуйста, введите число от 0 до 4")
        except ValueError:
            print("Пожалуйста, введите корректное число")


def collect_tasks(header, is_yesterday=True):
    """Собрать информацию о задачах"""
    tasks = []
    print(f"\n{header}")
    print("=" * 40)

    while True:
        task_name = input(
            "\nНазвание задачи (пустая строка для завершения): "
        ).strip()
        if not task_name:
            break

        status = get_task_status(is_yesterday)
        tasks.append((task_name, status))

    return tasks


def generate_report(yesterday_tasks, today_tasks):
    """Сгенерировать отчет в заданном формате"""
    report = "Hello\nMy update:\n"

    for i, (task, status) in enumerate(yesterday_tasks, 1):
        report += f"{i}. {task}\n"
        if status:
            report += f" - {status}\n"

    report += "My plans:\n"

    for i, (task, status) in enumerate(today_tasks, 1):
        report += f"{i}. {task}\n"
        if status:
            report += f" - {status}\n"

    return report.strip()


def main():
    """Основная функция программы"""
    print("Генератор отчетов по задачам")
    print("=" * 40)

    yesterday_tasks = collect_tasks("Вчерашние задачи:", is_yesterday=True)
    today_tasks = collect_tasks("Сегодняшние планы:", is_yesterday=False)

    report = generate_report(yesterday_tasks, today_tasks)

    print("\nСгенерированный отчет:")
    print("=" * 40)
    print(report)

    try:
        pyperclip.copy(report)
        print("\nОтчет скопирован в буфер обмена!")
    except Exception as e:
        print(f"\nНе удалось скопировать в буфер обмена: {e}")
        print("Для Wayland/Hyprland убедитесь, что установлен wl-clipboard")


if __name__ == "__main__":
    main()
