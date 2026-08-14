import QtQuick

// Базовый текст элементов панели: общий шрифт и цвет из темы,
// автоматически скрывается при пустом тексте.
Text {
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  color: Theme.text
  visible: text !== ""
  anchors.verticalCenter: parent.verticalCenter
}
