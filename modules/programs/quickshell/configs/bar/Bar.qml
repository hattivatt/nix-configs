import Quickshell
import QtQuick
import Quickshell.Hyprland
import ".."

PanelWindow {
  id: mainBar

  color: Theme.barBackground

  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: Theme.barHeight

  Item {
    anchors.fill: parent

    Row {
      id: leftSection
      anchors.left: parent.left
      spacing: 5

      Workspaces {}
    }

    // Заголовок активного окна, вручную центрируется между секциями
    PanelText {
      elide: Text.ElideMiddle
      text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
      color: Theme.textSub

      anchors.verticalCenter: parent.verticalCenter
      x: leftSection.width + (parent.width - leftSection.width - rightSection.width - width) / 2
      width: Math.min(implicitWidth, parent.width - leftSection.width - rightSection.width - 20)
    }

    Row {
      id: rightSection
      anchors.right: parent.right
      spacing: 5

      MprisWidget {}
      AudioWidget {}
      PhoneBattery {}
      NotificationWidget {}
      BatteryIndicator {}
      ClockWidget {}
      KeyboardLayout {}

      PanelText {
        color: Theme.accent
        text: "  |"
      }

      TrayWidget {
        window: mainBar
      }
    }
  }
}
