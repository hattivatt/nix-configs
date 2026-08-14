import Quickshell.Services.UPower
import ".."

// Заряд батареи ноутбука (display device UPower).
PanelText {
  text: {
    const device = UPower.displayDevice
    if (!device) return "0"

    const percentage = Math.trunc(device.percentage * 100)
    const level = device.percentage >= 0.75 ? 3
      : device.percentage >= 0.50 ? 2
      : device.percentage >= 0.25 ? 1
      : 0

    let icon = "" // заряжена / неизвестное состояние
    if (device.state === UPowerDeviceState.Discharging) {
      icon = ["󰂎", "󱊡", "󱊢", "󱊣"][level]
    } else if (device.state === UPowerDeviceState.Charging) {
      icon = ["󰢟", "󱊤", "󱊥", "󱊦"][level]
    }

    return percentage + "%" + icon
  }
}
