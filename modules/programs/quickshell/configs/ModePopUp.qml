import Quickshell
import QtQuick
import Quickshell.Hyprland

// Попап с именем активного submap'а Hyprland.
Item {
  PanelWindow {
    id: submapPopup
    visible: false

    anchors {
      left: true
      right: true
      bottom: true
    }
    exclusionMode: ExclusionMode.Ignore
    // Отступ снизу, заодно задающий высоту окна попапа
    margins.bottom: 600

    color: "transparent"

    Rectangle {
      anchors.centerIn: parent
      color: "#AAaaaaaa"
      radius: 20
      width: 300
      height: 100

      Text {
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 30
        font.bold: true
        text: submapPopup.submapText
      }
    }

    property string submapText: ""

    function showSubmap(name) {
      submapText = name
      visible = true
    }

    function hideSubmap() {
      visible = false
    }
  }

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === "submap") {
        const submapName = event.data || ""

        if (submapName !== "") {
          submapPopup.showSubmap(submapName)
        } else {
          submapPopup.hideSubmap()
        }
      }
    }
  }
}
