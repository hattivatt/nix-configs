import QtQuick
import Quickshell
import ".."

// Громкость вывода и микрофона.
// Колёсико — громкость, ЛКМ — мьют, ПКМ — pavucontrol.
Item {
  width: soundText.width
  height: Theme.barHeight

  PanelText {
    id: soundText

    text: {
      const volume = Math.round(Audio.volume * 100)
      const micVolume = Math.round(Audio.micVolume * 100)
      const volumeIcon = Audio.muted ? "󰖁 " : "󰋋 "
      return volume + "%" + volumeIcon + micVolume + "% "
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onWheel: wheel => {
      const step = wheel.angleDelta.y > 0 ? 0.01 : -0.01
      Audio.setVolume(Audio.volume + step)
    }

    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        Audio.toggleMute()
      } else if (mouse.button === Qt.RightButton) {
        Quickshell.execDetached(["pavucontrol-qt"])
      }
    }
  }
}
