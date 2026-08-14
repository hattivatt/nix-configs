# quickshell-configs

Конфиг [quickshell](https://quickshell.outfoxxed.me/): верхняя панель и пара виджетов для Hyprland.

## Структура

```
shell.qml                  ← входная точка (Bar + ModePopUp + PeripheralsWidget + OsdWidget)
Theme.qml                  ← синглтон: цвета (Catppuccin Mocha), шрифт, высота панели
Audio.qml                  ← синглтон Pipewire: громкость/мьют вывода и микрофона
PanelText.qml              ← базовый текст панели: дефолты из Theme, скрывается при пустом тексте
ModePopUp.qml              ← попап с именем активного submap'а Hyprland
OsdWidget.qml              ← OSD громкости и яркости: шкала по центру нижней половины экрана,
                             показывается при изменении и гаснет через ~2 с (без процентов)
PeripheralsWidget.qml      ← плавающий виджет с зарядом периферии (мышь, клава, наушники);
                             создаётся только если такие устройства есть
bar/
  Bar.qml                  ← окно панели и компоновка секций (лево/центр/право)
  Workspaces.qml           ← кнопки воркспейсов (без special:, по порядку id)
  MprisWidget.qml          ← Spotify: статус и трек. ЛКМ — play/pause, ПКМ — next
  AudioWidget.qml          ← громкость вывода и мика. Колёсико — громкость,
                             ЛКМ — мьют, ПКМ — pavucontrol
  PhoneBattery.qml         ← заряд телефона из скрипта phone_battery (опрос раз в 5 мин)
  NotificationWidget.qml   ← swaync: колокольчик, DND, счётчик непрочитанных.
                             ЛКМ — центр уведомлений, ПКМ — DND
  BatteryIndicator.qml     ← заряд батареи ноутбука (UPower display device)
  ClockWidget.qml          ← часы (hh:mm)
  KeyboardLayout.qml       ← раскладка клавиатуры (событие activelayout Hyprland)
  TrayWidget.qml           ← системный трей. ЛКМ — активация, ПКМ — меню, СКМ — secondary
```

## Заметки

- Синглтоны (`Theme`, `Audio`) лежат в корне; виджеты в `bar/` подключают их через `import ".."`.
- Цвета/шрифт меняются в одном месте — `Theme.qml`.
- Запуск: `quickshell --config /путь/к/папке`. Живой конфиг деплоится через home-manager
  в `~/.config/quickshell/main`.
