import QtQuick
import QtQuick.Controls
import Quickshell.Hyprland
import ".."

// Кнопки воркспейсов Hyprland: без special-воркспейсов, по порядку id.
Row {
  spacing: 5

  Repeater {
    model: Hyprland.workspaces.values
      .filter(workspace => !workspace.name.includes("special:"))
      .sort((a, b) => a.id - b.id)

    delegate: Button {
      id: workspaceButton

      required property var modelData

      text: modelData.name
      highlighted: modelData.active
      leftPadding: 5
      rightPadding: 10
      height: Theme.barHeight

      contentItem: Text {
        text: workspaceButton.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
        color: workspaceButton.highlighted ? Theme.textBright : Theme.textDim
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }

      background: Rectangle {
        color: workspaceButton.modelData.active ? Theme.surfaceActive : Theme.surface
        border.color: Theme.accent
        border.width: 1
        radius: 4
      }

      onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = ${modelData.id}})`)
    }
  }
}
