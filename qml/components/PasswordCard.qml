// Copyright (C) 2026 CharOfString <root@charofstring.cc>
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, version 3.

import QtQuick
import QtQuick.Controls
import QtQuick.Effects

// Modal login dialog, either for a chosen user (avatar and name above the
// password) or, with askUserName, for a user not in the list (user name and
// password fields, no avatar). The frame follows the DTK menus
// of gxde-dock's V23 mode (frame/util/styledmenu.cpp, v23menustyle.cpp):
// radius 8, frosted translucent window color, a dark outer and a light inner
// hairline and a soft drop shadow.
Popup {
  id: card

  property bool light: false
  property Item backdrop: null
  property bool askUserName: false
  property string userName: ""
  property url userAvatar
  property string errorText: ""
  property bool busy: false
  property url submitIconSource: "qrc:/icons/next-indicator.svg"

  // DTK standard palette, as used by V23MenuStyle
  readonly property color windowColor: light ? "#f8f8f8" : "#252525"
  readonly property real windowAlpha: light ? 0.45 : 0.6
  readonly property color highlightColor: light ? "#0081ff" : "#024cca"
  readonly property color highlightedTextColor: light ? "#ffffff" : "#f1f6ff"
  readonly property color textColor: light ? "#000000" : "#ffffff"
  readonly property color secondaryTextColor: light ? "#b2000000" : "#b2ffffff"
  readonly property color warningColor: "#be543c"
  readonly property color fieldColor: light ? "#14000000" : "#14ffffff"
  readonly property int frameRadius: 8
  readonly property int itemRadius: 6
  readonly property int backdropPadding: 32
  // True from the moment the dialog starts showing until it starts hiding,
  // for driving effects behind it in step with the transitions.
  property bool shown: false
  // Horizontal nudge for the failure shake; the owner adds it to x.
  property real shakeOffset: 0
  signal submitted(string userName, string password)

  function showError(message) {
    card.errorText = message
    card.busy = false
    passwordField.selectAll()
    passwordField.forceActiveFocus()
    shakeAnimation.restart()
  }

  function enteredUserName() {
    return card.askUserName ? userNameField.text.trim() : card.userName
  }

  function canSubmit() {
    return !card.busy && passwordField.text.length > 0
      && enteredUserName().length > 0
  }

  function submit() {
    if (!canSubmit()) {
      return
    }
    card.errorText = ""
    card.submitted(enteredUserName(), passwordField.text)
  }

  width: 300
  padding: 16
  topPadding: 20
  modal: true
  focus: true
  margins: 12
  transformOrigin: Popup.Center
  closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

  onAboutToShow: {
    card.shown = true
    userNameField.clear()
    passwordField.clear()
    card.errorText = ""
    card.busy = false
  }
  onAboutToHide: card.shown = false
  onOpened: {
    if (card.askUserName) {
      userNameField.forceActiveFocus()
    } else {
      passwordField.forceActiveFocus()
    }
  }

  Overlay.modal: Rectangle {
    color: "#33000000"

    Behavior on opacity {
      NumberAnimation {
        duration: 180
        easing.type: Easing.OutCubic
      }
    }
  }

  enter: Transition {
    ParallelAnimation {
      NumberAnimation {
        property: "opacity"
        from: 0.0
        to: 1.0
        duration: 180
        easing.type: Easing.OutCubic
      }
      NumberAnimation {
        property: "scale"
        from: 0.92
        to: 1.0
        duration: 180
        easing.type: Easing.OutCubic
      }
    }
  }

  exit: Transition {
    ParallelAnimation {
      NumberAnimation {
        property: "opacity"
        to: 0.0
        duration: 120
        easing.type: Easing.OutCubic
      }
      NumberAnimation {
        property: "scale"
        to: 0.96
        duration: 120
        easing.type: Easing.OutCubic
      }
    }
  }

  background: Item {
    id: frame

    // The backdrop region behind the card, padded so the blur has real
    // pixels to sample at the edges.
    readonly property rect backdropRect: {
      card.x
      card.y
      card.scale
      card.opened
      if (!card.backdrop || width <= 0 || height <= 0) {
        return Qt.rect(0, 0, 0, 0)
      }
      return frame.mapToItem(card.backdrop,
        -card.backdropPadding, -card.backdropPadding,
        width + card.backdropPadding * 2, height + card.backdropPadding * 2)
    }

    // Drop shadow, cut out under the card so the translucent fill does
    // not show a dark core.
    Item {
      id: shadowLayer

      anchors.fill: parent
      anchors.margins: -16
      layer.enabled: true
      layer.effect: MultiEffect {
        maskEnabled: true
        maskInverted: true
        maskSource: shadowCutout
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
      }

      Rectangle {
        id: shadowShape

        x: 16
        y: 16
        width: frame.width
        height: frame.height
        radius: card.frameRadius
        color: "black"
        visible: false
      }

      MultiEffect {
        anchors.fill: shadowShape
        source: shadowShape
        shadowEnabled: true
        shadowColor: "black"
        shadowOpacity: 0.2
        shadowBlur: 0.6
        blurMax: 16
        shadowVerticalOffset: 2
      }
    }

    Item {
      id: shadowCutout

      width: shadowLayer.width
      height: shadowLayer.height
      visible: false
      layer.enabled: true

      Rectangle {
        x: 16
        y: 16
        width: frame.width
        height: frame.height
        radius: card.frameRadius
        antialiasing: true
      }
    }

    ShaderEffectSource {
      id: backdropSource

      sourceItem: card.backdrop
      sourceRect: frame.backdropRect
      visible: false
      live: true
    }

    Item {
      id: backdropMask

      width: frame.width + card.backdropPadding * 2
      height: frame.height + card.backdropPadding * 2
      visible: false
      layer.enabled: true

      Rectangle {
        x: card.backdropPadding
        y: card.backdropPadding
        width: frame.width
        height: frame.height
        radius: card.frameRadius
        antialiasing: true
      }
    }

    MultiEffect {
      x: -card.backdropPadding
      y: -card.backdropPadding
      width: backdropMask.width
      height: backdropMask.height
      visible: card.backdrop !== null
      source: backdropSource
      autoPaddingEnabled: false
      blurEnabled: true
      blur: 1.0
      blurMax: 32
      maskEnabled: true
      maskSource: backdropMask
      maskThresholdMin: 0.5
      maskSpreadAtMin: 1.0
    }

    Rectangle {
      anchors.fill: parent
      radius: card.frameRadius
      antialiasing: true
      color: Qt.rgba(card.windowColor.r, card.windowColor.g,
        card.windowColor.b, card.backdrop ? card.windowAlpha : 1.0)
      border.width: 1
      border.color: card.light ? "#1f000000" : "#80000000"

      Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: card.frameRadius - 1
        antialiasing: true
        color: "transparent"
        border.width: 1
        border.color: card.light ? "#99ffffff" : "#1affffff"
      }
    }
  }

  contentItem: Column {
    spacing: 0

    UserAvatar {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 64
      height: 64
      radius: 13
      visible: !card.askUserName
      source: card.userAvatar
      name: card.userName
    }

    Text {
      width: parent.width
      topPadding: card.askUserName ? 0 : 10
      bottomPadding: 16
      text: card.askUserName ? qsTr("其他用户") : card.userName
      color: card.textColor
      font.pixelSize: 15
      font.weight: Font.Medium
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      renderType: Text.NativeRendering
    }

    CardField {
      id: userNameField

      visible: card.askUserName
      placeholderText: qsTr("用户名")
      inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
      onAccepted: {
        if (passwordField.text.length > 0) {
          card.submit()
        } else {
          passwordField.forceActiveFocus()
        }
      }
    }

    Item {
      width: 1
      height: 8
      visible: card.askUserName
    }

    CardField {
      id: passwordField

      rightPadding: submitButton.width + 8
      echoMode: TextInput.Password
      passwordCharacter: "\u2022"
      placeholderText: qsTr("密码")
      inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
      showError: card.errorText.length > 0
      onAccepted: card.submit()

      // A faint tinted rounded rect, only a shade off the field; the arrow
      // brightens once there is something to submit.
      Button {
        id: submitButton

        readonly property bool ready: card.canSubmit()

        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 28
        padding: 0
        focusPolicy: Qt.NoFocus
        hoverEnabled: true
        enabled: ready
        display: AbstractButton.IconOnly
        icon.source: card.submitIconSource
        icon.width: 16
        icon.height: 16
        icon.color: ready ? card.textColor : card.secondaryTextColor
        onClicked: card.submit()

        background: Rectangle {
          radius: 4
          color: !submitButton.ready ? (card.light ? "#08000000" : "#08ffffff")
            : submitButton.down ? (card.light ? "#0a000000" : "#0affffff")
            : submitButton.hovered ? (card.light ? "#1f000000" : "#1fffffff")
            : (card.light ? "#14000000" : "#14ffffff")

          Behavior on color {
            ColorAnimation {
              duration: 120
            }
          }
        }

        HoverHandler {
          enabled: submitButton.ready
          cursorShape: Qt.PointingHandCursor
        }
      }
    }

    // Unfolds below the field; keeps the last message while folding away
    // so the text does not vanish before the row has closed.
    Item {
      id: errorRow

      property string message: ""
      readonly property bool active: card.errorText.length > 0

      width: parent.width
      height: active ? errorLabel.implicitHeight : 0
      clip: true

      Connections {
        target: card
        function onErrorTextChanged() {
          if (card.errorText.length > 0) {
            errorRow.message = card.errorText
          }
        }
      }

      Behavior on height {
        NumberAnimation {
          duration: 180
          easing.type: Easing.OutCubic
        }
      }

      Text {
        id: errorLabel

        width: parent.width
        topPadding: 6
        leftPadding: 4
        text: errorRow.message
        color: card.warningColor
        opacity: errorRow.active ? 1.0 : 0.0
        font.pixelSize: 12
        wrapMode: Text.Wrap
        renderType: Text.NativeRendering

        Behavior on opacity {
          NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
          }
        }
      }
    }
  }

  component CardField: TextField {
    id: field

    property bool showError: false

    width: parent ? parent.width : 0
    height: 36
    leftPadding: 10
    rightPadding: 10
    verticalAlignment: TextInput.AlignVCenter
    placeholderTextColor: card.secondaryTextColor
    color: card.textColor
    selectionColor: card.highlightColor
    selectedTextColor: card.highlightedTextColor
    font.pixelSize: 14
    enabled: !card.busy
    onTextEdited: card.errorText = ""

    background: Rectangle {
      radius: card.itemRadius
      color: card.fieldColor
      // Always 1px wide so focus fades the border in through its alpha
      // instead of popping it on.
      border.width: 1
      border.color: field.showError ? card.warningColor
        : field.activeFocus ? (card.light ? "#66000000" : "#99ffffff")
        : (card.light ? "#00000000" : "#00ffffff")

      Behavior on border.color {
        ColorAnimation {
          duration: 160
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  SequentialAnimation {
    id: shakeAnimation

    NumberAnimation {
      target: card
      property: "shakeOffset"
      to: -8
      duration: 50
      easing.type: Easing.OutQuad
    }
    NumberAnimation {
      target: card
      property: "shakeOffset"
      to: 7
      duration: 80
      easing.type: Easing.InOutQuad
    }
    NumberAnimation {
      target: card
      property: "shakeOffset"
      to: -4
      duration: 70
      easing.type: Easing.InOutQuad
    }
    NumberAnimation {
      target: card
      property: "shakeOffset"
      to: 2
      duration: 60
      easing.type: Easing.InOutQuad
    }
    NumberAnimation {
      target: card
      property: "shakeOffset"
      to: 0
      duration: 50
      easing.type: Easing.OutQuad
    }
  }
}
