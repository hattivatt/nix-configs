import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// Заряд телефона из скрипта phone_battery, опрос раз в 5 минут.
PanelText {
  id: root

  Process {
    id: phoneProcess

    command: ["phone_battery"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.text = this.text
    }
  }

  Timer {
    interval: 300000
    running: true
    repeat: true

    onTriggered: phoneProcess.running = true
  }
}
