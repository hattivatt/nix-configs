pragma Singleton

import QtQuick
import Quickshell

// Общая тема: цвета (Catppuccin Mocha), шрифт и размеры панели.
Singleton {
  // Фоны
  readonly property color barBackground: "#D911111b"
  readonly property color surface: "#0b1010"       // неактивный воркспейс
  readonly property color surfaceActive: "#374146" // активный воркспейс
  readonly property color hover: "#45475a"         // наведение в трее

  // Текст
  readonly property color text: "#bac2de"
  readonly property color textBright: "#cdd6f4"
  readonly property color textSub: "#a6adc8"
  readonly property color textDim: "#7f849c"
  readonly property color textMuted: "#aaaaaa"
  readonly property color accent: "#f38ba8"

  // Шрифт и размеры
  readonly property string fontFamily: "Nerd Font Propo"
  readonly property int fontSize: 15
  readonly property int barHeight: 30
}
