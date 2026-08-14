import QtQuick
import Quickshell.Services.Mpris
import ".."

// Индикатор Spotify: состояние воспроизведения и трек.
// ЛКМ — play/pause, ПКМ — следующий трек.
PanelText {
  id: root

  color: Theme.accent

  readonly property MprisPlayer activePlayer:
    Mpris.players.values.find(player => player.identity === "Spotify") ?? null

  text: {
    if (!activePlayer) return ""

    const status = activePlayer.isPlaying ? "  " : " 󰏤 "
    const shuffle = activePlayer.shuffle ? " 󰒟  " : "  "
    const repeat = activePlayer.loopState === MprisLoopState.Track ? " 󰑘  "
      : activePlayer.loopState === MprisLoopState.Playlist ? " 󰑖  "
      : " 󰑗  "

    return shuffle + repeat + status + activePlayer.trackArtist + " - " + activePlayer.trackTitle
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: mouse => {
      if (!root.activePlayer) return

      if (mouse.button === Qt.LeftButton) {
        root.activePlayer.togglePlaying()
      } else if (mouse.button === Qt.RightButton) {
        root.activePlayer.next()
      }
    }
  }
}
