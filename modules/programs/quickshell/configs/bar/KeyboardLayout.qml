import QtQuick
import Quickshell.Hyprland
import ".."

// Текущая раскладка клавиатуры (событие activelayout Hyprland).
PanelText {
  id: root

  property string currentLayout: ""

  text: {
    switch (currentLayout) {
      case "English": return "EN"
      case "Russian": return "Ру"
      default: return ""
    }
  }

  font.pixelSize: 16
  font.bold: true

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === "activelayout") {
        const layout = event.data || ""

        if (layout.includes("English")) {
          root.currentLayout = "English"
        } else if (layout.includes("Russian")) {
          root.currentLayout = "Russian"
        } else {
          root.currentLayout = ""
        }
      }
    }
  }
}
