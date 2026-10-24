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
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Window

Window {
  id: root

  property url backgroundUri: ""
  property date now: new Date()
  property color iconTint: "white"
  property bool isGxdeOs: false
  property string gxdeReleaseLabel: ""
  property var userModel: []
  property real activeBackgroundScale: 1.08
  property real activeBackgroundBlur: 0.55
  property real loginProgress: clockView.positionedAtTop ? 1.0 : 0.0
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
  signal userSelected(int index, var user)
  signal manualLoginRequested()
  signal keyboardLayoutRequested()
  signal powerRequested()

  width: 640
  height: 480
  visible: true
  title: "GXDM Greeter"
  color: "#101010"

  Behavior on loginProgress {
    NumberAnimation {
      duration: 250
      easing.type: Easing.Linear
    }
  }

  function dateLabel(value) {
    return value.getFullYear() + "年"
      + (value.getMonth() + 1) + "月"
      + value.getDate() + "日 "
      + weekdays[value.getDay()]
  }

  function requestLogin() {
    clockView.positionedAtTop = true
    root.loginRequested()
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  Item {
    id: backgroundLayer

    anchors.fill: parent
    scale: 1.0 + (root.activeBackgroundScale - 1.0) * root.loginProgress

    Item {
      id: backgroundSource

      anchors.fill: parent

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
    }

    MultiEffect {
      anchors.fill: backgroundSource
      source: backgroundSource
      visible: root.loginProgress > 0
      blurEnabled: true
      blurMax: 32
      blur: root.activeBackgroundBlur * root.loginProgress
      autoPaddingEnabled: false
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
      if (event.key === Qt.Key_Escape) {
        clockView.positionedAtTop = false
      } else {
        root.requestLogin()
      }
      event.accepted = true
    }
  }

  TapHandler {
    acceptedButtons: Qt.AllButtons
    onTapped: root.requestLogin()
  }

  Item {
    id: clockView

    property bool positionedAtTop: false

    x: (parent.width - width) / 2
    y: positionedAtTop ? 72 : (parent.height - height) / 2
    width: Math.max(timeLabel.width, promptLabel.width)
    height: timeLabel.inkHeight + 8 + promptLabel.inkHeight

    Behavior on y {
      NumberAnimation {
        duration: 250
        easing.type: Easing.OutExpo
      }
    }

    ShadowText {
      id: timeLabel

      anchors.horizontalCenter: parent.horizontalCenter
      y: -inkTop
      text: Qt.formatTime(root.now, "hh:mm")
      pixelSize: 48
      weight: Font.Black
      shadowOpacity: 0.24
    }

    ShadowText {
      id: promptLabel

      anchors.horizontalCenter: parent.horizontalCenter
      y: timeLabel.inkHeight + 8 - inkTop
      text: dateLabel(root.now)
      pixelSize: 16
      weight: Font.Light
      shadowOpacity: 0.22
    }
  }

  UserSelecter {
    id: userSelecter

    anchors.centerIn: parent
    width: Math.min(implicitWidth, Math.max(0, parent.width - 48))
    model: root.userModel
    foregroundColor: "white"
    visible: clockView.positionedAtTop || root.loginProgress > 0
    enabled: clockView.positionedAtTop
    opacity: root.loginProgress
    onUserConfirmed: (index, user) => root.userSelected(index, user)
    onNotListedRequested: root.manualLoginRequested()
  }

  Item {
    id: gxdeInfoView

    property bool meetsAdditionalVisibilityConditions: true
    property real revealProgress: clockView.positionedAtTop ? 1.0 : 0.0
    readonly property real bottomMargin: 12
    readonly property real hiddenY: parent.height - height / 2
    readonly property real shownY: parent.height - height - bottomMargin
    readonly property real logoRightInkPadding: gxdeLogo.width * 5 / 150
    readonly property real versionLeftMargin: 5 - logoRightInkPadding
    readonly property rect versionInkBounds:
      versionMetrics.tightBoundingRect(gxdeVersion.text)
    readonly property real versionInkTop:
      gxdeVersion.baselineOffset + versionInkBounds.y

    anchors.left: parent.left
    anchors.leftMargin: 12
    visible: root.isGxdeOs
      && root.gxdeReleaseLabel.length > 0
      && (clockView.positionedAtTop || revealProgress > 0)
      && meetsAdditionalVisibilityConditions
    opacity: revealProgress
    y: hiddenY + (shownY - hiddenY) * revealProgress
    width: gxdeLogo.width + versionLeftMargin + gxdeVersion.implicitWidth
    height: gxdeLogo.height

    Behavior on revealProgress {
      NumberAnimation {
        duration: 140
        easing.type: Easing.OutCubic
      }
    }

    FontMetrics {
      id: versionMetrics
      font: gxdeVersion.font
    }

    Image {
      id: gxdeLogo
      anchors.bottom: parent.bottom
      anchors.left: parent.left

      width: Math.round(height * 150 / 35)
      height: 32
      source: "qrc:/icons/gxde.png"
      fillMode: Image.PreserveAspectFit
      smooth: true
      mipmap: false
    }

    Text {
      id: gxdeVersion
      anchors.left: gxdeLogo.right
      anchors.leftMargin: gxdeInfoView.versionLeftMargin
      y: -gxdeInfoView.versionInkTop
      text: root.gxdeReleaseLabel
      color: "#d0d0d0"
      font.family: "Source Han Sans"
      font.pixelSize: 10
      font.weight: Font.Light
      renderType: Text.NativeRendering
    }
  }

  Row {
    id: operationView

    property real revealProgress: clockView.positionedAtTop ? 1.0 : 0.0
    readonly property real bottomMargin: 12
    readonly property real hiddenY: parent.height - height / 2
    readonly property real shownY: parent.height - height - bottomMargin

    anchors.right: parent.right
    anchors.rightMargin: 12
    visible: clockView.positionedAtTop || revealProgress > 0
    opacity: revealProgress
    y: hiddenY + (shownY - hiddenY) * revealProgress
    spacing: 12

    Behavior on revealProgress {
      NumberAnimation {
        duration: 140
        easing.type: Easing.OutCubic
      }
    }

    IconButton {
      source: "qrc:/icons/keyboard.svg"
      tint: root.iconTint
      onClicked: root.keyboardLayoutRequested()
    }

    IconButton {
      source: "qrc:/icons/power.svg"
      tint: root.iconTint
      onClicked: root.powerRequested()
    }
  }

  component ShadowText: Item {
    id: shadowText

    property alias text: label.text
    property int pixelSize: 24
    property int weight: Font.Normal
    property real shadowOpacity: 0.25
    readonly property rect inkBounds: textMetrics.tightBoundingRect(label.text)
    readonly property real inkTop: label.baselineOffset + inkBounds.y
    readonly property real inkHeight: inkBounds.height

    implicitWidth: label.implicitWidth + 4
    implicitHeight: label.implicitHeight + 4
    width: implicitWidth
    height: implicitHeight

    FontMetrics {
      id: textMetrics
      font: label.font
    }

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

  component IconButton: ToolButton {
    id: iconButton

    property url source
    property color tint: "white"

    width: 32
    height: 32
    padding: 4
    focusPolicy: Qt.NoFocus
    hoverEnabled: true
    display: AbstractButton.IconOnly
    icon.source: iconButton.source
    icon.width: 24
    icon.height: 24
    icon.color: iconButton.tint
    opacity: hovered ? 1.0 : 0.86

    background: Item {
    }

    HoverHandler {
      cursorShape: Qt.PointingHandCursor
    }
  }
}
