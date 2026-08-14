import QtQuick
import QtQuick.Controls
import Quickshell.Services.SystemTray
import ".."

// Системный трей. ЛКМ — активация, ПКМ — меню, СКМ — secondaryActivate.
Row {
  id: root
  spacing: 5

  // Окно панели, нужно для позиционирования меню трея
  required property var window

  Repeater {
    model: SystemTray.items

    delegate: ToolButton {
      id: trayButton

      required property var modelData

      icon.source: modelData && modelData.icon ? modelData.icon : ""
      icon.width: 20
      icon.height: 20
      icon.color: Theme.text

      background: Rectangle {
        color: trayMouseArea.containsMouse ? Theme.hover : "transparent"
        border.width: 0
      }

      MouseArea {
        id: trayMouseArea

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        hoverEnabled: true

        onClicked: mouse => {
          const item = trayButton.modelData
          if (!item) return

          const globalPos = mapToGlobal(mouseX, mouseY)
          if (mouse.button === Qt.LeftButton) {
            if (item.onlyMenu) {
              item.display(root.window, globalPos.x, globalPos.y)
            } else {
              item.activate()
            }
          } else if (mouse.button === Qt.RightButton) {
            if (item.hasMenu) {
              item.display(root.window, globalPos.x, globalPos.y)
            }
          } else if (mouse.button === Qt.MiddleButton) {
            item.secondaryActivate()
          }
        }
      }

      ToolTip.text: {
        if (modelData && modelData.tooltipTitle && modelData.tooltipTitle !== "") {
          return modelData.tooltipTitle
        } else if (modelData && modelData.title && modelData.title !== "") {
          return modelData.title
        } else {
          return "Unknown"
        }
      }
    }
  }
}
