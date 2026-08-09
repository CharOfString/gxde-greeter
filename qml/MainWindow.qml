// Copyright (C) CharOfString <root@charofstring.cc>
// 
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, version 3.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import QtQuick
import QtQuick.Window

Window {
  id: root

  property url backgroundUri: ""
  property date now: new Date()
  readonly property var weekdays: [
    "星期日",
    "星期一",
    "星期二",
    "星期三",
    "星期四",
    "星期五",
    "星期六"
  ]

  signal loginRequested()
  signal keyboardLayoutRequested()
  signal powerRequested()

  width: 640
  height: 480
  visible: true
  title: "GXDM Greeter"
  color: "#101010"

  function dateLabel(value) {
    return value.getFullYear() + "年"
      + (value.getMonth() + 1) + "月"
      + value.getDate() + "日 "
      + weekdays[value.getDay()]
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  Image {
    anchors.fill: parent
    source: root.backgroundUri
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: false
    smooth: true
    visible: root.backgroundUri.toString() !== ""
  }

  Rectangle {
    anchors.fill: parent
    visible: root.backgroundUri.toString() === ""
    gradient: Gradient {
      GradientStop { position: 0; color: "#e9def8" }
      GradientStop { position: 1; color: "#cfdff2" }
    }
  }

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#00000000" }
      GradientStop { position: 0.55; color: "#00000000" }
      GradientStop { position: 1.0; color: "#36000000" }
    }
  }

  Item {
    id: keyCatcher

    anchors.fill: parent
    focus: true

    Component.onCompleted: forceActiveFocus()

    Keys.onPressed: (event) => {
      root.loginRequested()
      event.accepted = true
    }
  }

  Item {
    id: centerPanel

    anchors.centerIn: parent
    width: Math.max(timeLabel.width, promptLabel.width)
    height: timeLabel.height + 18 + promptLabel.height

    ShadowText {
      id: timeLabel

      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.formatTime(root.now, "hh:mm")
      pixelSize: 72
      weight: Font.Black
      shadowOpacity: 0.24
    }

    ShadowText {
      id: promptLabel

      anchors.horizontalCenter: parent.horizontalCenter
      y: timeLabel.height + 18
      text: "按任意键登录"
      pixelSize: 24
      weight: Font.Normal
      shadowOpacity: 0.22
    }
  }

  ShadowText {
    anchors.left: parent.left
    anchors.leftMargin: 21
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 9
    text: root.dateLabel(root.now)
    pixelSize: 24
    weight: Font.Normal
    shadowOpacity: 0.22
  }

  Row {
    anchors.right: parent.right
    anchors.rightMargin: 22
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 13
    width: implicitWidth
    height: implicitHeight
    spacing: 15

    IconButton {
      iconName: "keyboard"
      onClicked: root.keyboardLayoutRequested()
    }

    IconButton {
      iconName: "power"
      onClicked: root.powerRequested()
    }
  }

  component ShadowText: Item {
    id: shadowText

    property alias text: label.text
    property int pixelSize: 24
    property int weight: Font.Normal
    property real shadowOpacity: 0.25

    implicitWidth: label.implicitWidth + 4
    implicitHeight: label.implicitHeight + 4
    width: implicitWidth
    height: implicitHeight

    Text {
      x: 2
      y: 2
      text: label.text
      color: Qt.rgba(0, 0, 0, shadowText.shadowOpacity)
      font.family: "Source Han Sans"
      font.pixelSize: shadowText.pixelSize
      font.weight: shadowText.weight
      renderType: Text.NativeRendering
    }

    Text {
      id: label
      color: "white"
      font.family: "Source Han Sans"
      font.pixelSize: shadowText.pixelSize
      font.weight: shadowText.weight
      renderType: Text.NativeRendering
    }
  }

  component IconButton: Item {
    id: iconButton

    property string iconName: ""
    signal clicked()

    width: 32
    height: 32

    Canvas {
      anchors.fill: parent
      opacity: iconMouse.containsMouse ? 1.0 : 0.86

      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.strokeStyle = "white"
        ctx.fillStyle = "white"
        ctx.lineWidth = 2
        ctx.lineCap = "round"
        ctx.lineJoin = "round"

        if (iconButton.iconName === "keyboard") {
          roundedRect(ctx, 3, 8, 26, 16, 3)
          ctx.stroke()

          for (var row = 0; row < 2; ++row) {
            for (var col = 0; col < 4; ++col) {
              ctx.fillRect(7 + col * 5.4, 12 + row * 5, 1.6, 1.6)
            }
          }

          ctx.beginPath()
          ctx.moveTo(13, 22)
          ctx.lineTo(19, 22)
          ctx.stroke()
        } else {
          ctx.beginPath()
          ctx.arc(16, 18, 9, Math.PI * 0.72, Math.PI * 2.28, false)
          ctx.stroke()

          ctx.beginPath()
          ctx.moveTo(16, 6)
          ctx.lineTo(16, 15)
          ctx.stroke()
        }
      }

      function roundedRect(ctx, x, y, width, height, radius) {
        ctx.beginPath()
        ctx.moveTo(x + radius, y)
        ctx.lineTo(x + width - radius, y)
        ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
        ctx.lineTo(x + width, y + height - radius)
        ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
        ctx.lineTo(x + radius, y + height)
        ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
        ctx.lineTo(x, y + radius)
        ctx.quadraticCurveTo(x, y, x + radius, y)
        ctx.closePath()
      }
    }

    MouseArea {
      id: iconMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: iconButton.clicked()
    }
  }
}
