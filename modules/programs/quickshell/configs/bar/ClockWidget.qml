import QtQuick
import Quickshell
import ".."

PanelText {
  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  text: Qt.formatDateTime(clock.date, "hh:mm")
}
