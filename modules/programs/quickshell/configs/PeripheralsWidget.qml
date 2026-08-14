import Quickshell
import QtQuick
import Quickshell.Services.UPower

// Плавающий виджет с зарядом периферии (мышь, клавиатура, наушники).
// Создаётся только когда такие устройства есть в системе.
Loader {
  id: root

  readonly property var peripheralDevices: UPower.devices.values.filter(device =>
    !device.nativePath.includes("line_power") &&
    !device.nativePath.includes("BAT0") &&
    device.percentage !== 0
  )

  active: peripheralDevices.length > 0

  sourceComponent: PanelWindow {
    color: "#AA0b1010" // Semi-transparent background

    anchors {
      top: true
      right: true
    }
    margins {
      top: 10
      right: 10
    }
    aboveWindows: false
    implicitWidth: 250
    implicitHeight: 300

    Column {
      anchors.centerIn: parent
      spacing: 5
      padding: 5

      Repeater {
        model: root.peripheralDevices

        delegate: Text {
          required property var modelData

          text: {
            const percentage = Math.round(modelData.percentage * 100) + "%"
            let icon = ""

            switch (modelData.type) {
              case UPowerDeviceType.Mouse: icon = " "; break;
              case UPowerDeviceType.Keyboard: icon = " "; break;
              case UPowerDeviceType.Headset: icon = "󰋋  "; break;
              case UPowerDeviceType.Headphones: icon = "󰋋  "; break;
              case UPowerDeviceType.Tablet: icon = " "; break;
              default: icon = modelData.model ? modelData.model.substring(0, 3).toUpperCase() + " " : " "
            }

            return icon + percentage
          }

          color: Theme.textMuted
          font.pixelSize: 50
          font.family: "Iosevka Nerd Font"
        }
      }
    }
  }
}
