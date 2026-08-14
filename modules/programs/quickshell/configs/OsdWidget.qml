import Quickshell
import QtQuick
import Quickshell.Io

// Всплывающий OSD громкости и яркости: показывается, пока меняется
// громкость/мьют (Pipewire) или яркость (опрос sysfs), и гаснет через
// пару секунд после последнего изменения. Расположен по центру нижней
// половины экрана.
Item {
  id: root

  // Сколько жить после последнего изменения
  readonly property int osdTimeout: 1600

  // Игнорируем изменения в первые секунды после старта, чтобы OSD
  // не вспыхивал, пока Pipewire и подсистема яркости инициализируются.
  property bool armed: false
  Timer {
    interval: 2000
    running: true
    onTriggered: root.armed = true
  }

  // Что сейчас показываем
  property bool showingVolume: true
  property int volumePercent: Math.round(Audio.volume * 100)
  property bool muted: Audio.muted
  property int brightnessPercent: 0
  property int lastBrightness: -1

  // --- Громкость ---
  Connections {
    target: Audio

    function onVolumeChanged() {
      root.showVolume()
    }

    function onMutedChanged() {
      root.showVolume()
    }
  }

  function showVolume() {
    if (!root.armed) return
    root.showingVolume = true
    osdWindow.present()
  }

  // --- Яркость: системного события нет, поэтому опрашиваем состояние ---
  function pollBrightness() {
    brightnessProc.exec(["sh", "-c",
      "brightnessctl -m 2>/dev/null | head -n1 || "
      + "{ b=$(cat /sys/class/backlight/*/brightness 2>/dev/null | head -n1); "
      + "m=$(cat /sys/class/backlight/*/max_brightness 2>/dev/null | head -n1); "
      + "[ -n \"$b\" ] && [ -n \"$m\" ] && echo $((b * 100 / m))%; }"
    ])
  }

  function onBrightness(percent) {
    root.brightnessPercent = percent
    const changed = percent !== root.lastBrightness
    root.lastBrightness = percent
    if (root.armed && changed) {
      root.showingVolume = false
      osdWindow.present()
    }
  }

  Process {
    id: brightnessProc

    stdout: StdioCollector {
      onStreamFinished: {
        // Текст может накапливаться между запусками, поэтому берём
        // последнюю строку и из неё — поле с процентами.
        const lines = this.text.trim().split("\n")
        const fields = lines[lines.length - 1].split(",")
        const percentField = fields.find(field => field.includes("%"))
        const percent = parseInt(percentField)
        if (!isNaN(percent)) root.onBrightness(percent)
      }
    }
  }

  Timer {
    id: pollTimer
    interval: 300
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.pollBrightness()
  }

  // --- Окно OSD ---
  PanelWindow {
    id: osdWindow
    visible: false
    color: "transparent"

    anchors {
      left: true
      right: true
      bottom: true
    }
    exclusionMode: ExclusionMode.Ignore
    // Вся площадь окна клик-through
    mask: Region {
      item: maskRect
      intersection: Intersection.Xor
    }

    implicitHeight: 110
    // Центр окна — ровно в середине нижней половины экрана (3/4 высоты)
    margins.bottom: osdWindow.screen ? osdWindow.screen.height / 4 - osdWindow.implicitHeight / 2 : 0

    function present() {
      hideWindowTimer.stop()
      pill.opacity = 1
      osdWindow.visible = true
      hideTimer.restart()
    }

    function dismiss() {
      pill.opacity = 0
      hideWindowTimer.restart()
    }

    Timer {
      id: hideTimer
      interval: root.osdTimeout
      onTriggered: osdWindow.dismiss()
    }

    Timer {
      id: hideWindowTimer
      interval: 200
      onTriggered: osdWindow.visible = false
    }

    // Служебный прямоугольник для маски кликов
    Rectangle {
      id: maskRect
      anchors.fill: parent
      visible: false
    }

    Rectangle {
      id: pill
      anchors.centerIn: parent

      width: 320
      height: 88
      radius: 22
      color: "#E611111b"
      border.color: "#55374146"
      border.width: 1
      opacity: 0

      Behavior on opacity {
        NumberAnimation {
          duration: 150
        }
      }

      Row {
        anchors.centerIn: parent
        spacing: 20

        Text {
          anchors.verticalCenter: parent.verticalCenter
          font.family: Theme.fontFamily
          font.pixelSize: 44
          color: Theme.textBright
          text: root.showingVolume
            ? (root.muted ? "󰖁" : root.volumePercent < 33 ? "󰕿" : root.volumePercent < 66 ? "󰖀" : "󰕾")
            : "󰃟"
        }

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 200
          height: 10
          radius: 5
          color: Theme.surfaceActive

          Rectangle {
            id: fillRect
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * Math.max(0, Math.min(100, root.showingVolume ? root.volumePercent : root.brightnessPercent)) / 100
            height: parent.height
            radius: 5
            color: root.showingVolume && root.muted ? Theme.textDim : Theme.accent
          }
        }
      }
    }
  }
}
