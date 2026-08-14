import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// Иконка уведомлений swaync: колокольчик, DND и счётчик непрочитанных.
// ЛКМ — открыть центр уведомлений, ПКМ — переключить DND.
Item {
  width: notificationText.width
  height: Theme.barHeight

  PanelText {
    id: notificationText

    property bool dnd: false

    text: dnd ? "" : ""
  }

  Rectangle {
    id: unreadIndicator

    property int count: 0

    width: 6
    height: 6
    radius: 3
    color: "red"
    visible: count > 0
    anchors.right: notificationText.right
    anchors.top: notificationText.top
    anchors.topMargin: 2
  }

  Process {
    command: ["swaync-client", "-s"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        try {
          const out = JSON.parse(data)
          unreadIndicator.count = out.count || 0
          notificationText.dnd = out.dnd || false
        } catch (error) {
          console.error("JSON parse error:", error)
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        Quickshell.execDetached(["swaync-client", "-t", "-sw"])
      } else if (mouse.button === Qt.RightButton) {
        Quickshell.execDetached(["swaync-client", "-d", "-sw"])
      }
    }
  }
}
