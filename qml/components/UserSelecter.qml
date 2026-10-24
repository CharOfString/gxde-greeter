// Copyright (C) 2026 CharOfString <root@charofstring.cc>
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, version 3.

import QtQuick
import QtQuick.Controls
import QtQuick.Effects

FocusScope {
  id: root

  property var model: []
  property alias currentIndex: userList.currentIndex
  property color foregroundColor: "white"
  property color avatarFallbackColor: "#b9bdc2"
  property color selectionColor: "#ffffff"
  property int avatarSize: 68
  property int avatarRadius: 14
  property int delegateWidth: 96
  property int delegateSpacing: 8
  property int navigationSize: 32
  property int navigationGutter: 40
  property int namePixelSize: 13
  property bool showNotListed: true
  property string notListedText: qsTr("未列出？")
  property url previousIconSource: "qrc:/icons/prev.svg"
  property url nextIconSource: "qrc:/icons/next.svg"

  signal userConfirmed(int index, var user)
  signal notListedRequested()

  implicitWidth: 560
  implicitHeight: carousel.height + (showNotListed ? 30 : 0)
  width: implicitWidth
  height: implicitHeight

  function modelCount() {
    if (root.model === null || root.model === undefined) {
      return 0
    }
    if (typeof root.model.count === "number") {
      return root.model.count
    }
    return typeof root.model.length === "number" ? root.model.length : 0
  }

  function userAt(index) {
    if (index < 0 || index >= modelCount()) {
      return ({})
    }
    if (typeof root.model.get === "function") {
      return root.model.get(index)
    }
    return root.model[index]
  }

  function fullNameFor(user) {
    if (!user) {
      return ""
    }
    return user.fullName || user.displayName || user.name || user.username || ""
  }

  function avatarFor(user) {
    if (!user) {
      return ""
    }
    return user.avatar || user.avatarUrl || user.icon || ""
  }

  function initialsFor(name) {
    const trimmedName = String(name || "").trim()
    if (trimmedName.length === 0) {
      return "?"
    }

    const words = trimmedName.split(/\s+/)
    if (words.length === 1) {
      return words[0].charAt(0).toUpperCase()
    }
    return (words[0].charAt(0) + words[words.length - 1].charAt(0))
      .toUpperCase()
  }

  function confirmUser(index) {
    if (index < 0 || index >= modelCount()) {
      return
    }
    userList.currentIndex = index
    root.userConfirmed(index, userAt(index))
  }

  function boundedContentX(value) {
    return Math.max(0, Math.min(userList.maximumContentX, value))
  }

  function scrollTo(value) {
    userList.cancelFlick()
    contentAnimation.stop()
    contentAnimation.to = boundedContentX(value)
    contentAnimation.start()
  }

  function scrollPage(direction) {
    const stride = root.delegateWidth + root.delegateSpacing
    const visibleItems = Math.max(1, Math.floor(userList.width / stride))
    scrollTo(userList.contentX + direction * visibleItems * stride)
  }

  Item {
    id: carousel

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: root.avatarSize + 30

    ListView {
      id: userList

      readonly property real maximumContentX: Math.max(0, contentWidth - width)
      readonly property bool hasOverflow: contentWidth > width + 0.5

      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      width: Math.min(Math.max(0, parent.width - root.navigationGutter * 2),
        Math.max(root.delegateWidth, contentWidth))
      height: parent.height
      model: root.model
      currentIndex: -1
      orientation: ListView.Horizontal
      spacing: root.delegateSpacing
      clip: true
      interactive: hasOverflow
      boundsBehavior: Flickable.DragAndOvershootBounds
      boundsMovement: Flickable.FollowBoundsBehavior
      flickDeceleration: 2600
      maximumFlickVelocity: 3600
      reuseItems: true
      keyNavigationEnabled: true

      rebound: Transition {
        NumberAnimation {
          properties: "x,y"
          duration: 180
          easing.type: Easing.OutCubic
        }
      }

      Keys.onLeftPressed: root.scrollPage(-1)
      Keys.onRightPressed: root.scrollPage(1)
      Keys.onReturnPressed: root.confirmUser(currentIndex)
      Keys.onEnterPressed: root.confirmUser(currentIndex)

      delegate: Item {
        id: userDelegate

        required property int index
        readonly property var userData: root.userAt(index)
        readonly property string fullName: root.fullNameFor(userData)
        readonly property url avatarSource: root.avatarFor(userData)

        width: root.delegateWidth
        height: userList.height

        Rectangle {
          id: avatarFrame

          anchors.top: parent.top
          anchors.horizontalCenter: parent.horizontalCenter
          width: root.avatarSize
          height: root.avatarSize
          radius: root.avatarRadius
          color: root.avatarFallbackColor
          antialiasing: true
          border.width: userList.currentIndex === userDelegate.index
            || avatarHover.hovered ? 2 : 0
          border.color: root.selectionColor

          Text {
            anchors.centerIn: parent
            text: root.initialsFor(userDelegate.fullName)
            color: "#4f555b"
            font.pixelSize: Math.round(root.avatarSize * 0.34)
            font.weight: Font.Medium
          }

          Rectangle {
            id: avatarMask

            anchors.fill: parent
            radius: avatarFrame.radius
            color: "white"
            antialiasing: true
            visible: false
            layer.enabled: true
            layer.smooth: true
            layer.samples: 4
          }

          Image {
            id: avatarImage

            anchors.fill: parent
            source: userDelegate.avatarSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true
            visible: source.toString() !== "" && status === Image.Ready
            layer.enabled: visible
            layer.smooth: true
            layer.effect: MultiEffect {
              maskEnabled: true
              maskSource: avatarMask
            }
          }
        }

        Text {
          anchors.top: avatarFrame.bottom
          anchors.topMargin: 7
          anchors.horizontalCenter: avatarFrame.horizontalCenter
          width: parent.width
          text: userDelegate.fullName
          color: root.foregroundColor
          font.pixelSize: root.namePixelSize
          font.weight: Font.Normal
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          maximumLineCount: 1
          renderType: Text.NativeRendering
        }

        TapHandler {
          onTapped: root.confirmUser(userDelegate.index)
        }

        HoverHandler {
          id: avatarHover
          cursorShape: Qt.PointingHandCursor
        }
      }

      WheelHandler {
        target: null
        blocking: true
        onWheel: (event) => {
          if (!userList.hasOverflow) {
            event.accepted = false
            return
          }

          const pixelDelta = Math.abs(event.pixelDelta.x)
            > Math.abs(event.pixelDelta.y)
              ? event.pixelDelta.x : event.pixelDelta.y
          if (pixelDelta !== 0) {
            contentAnimation.stop()
            userList.cancelFlick()
            userList.contentX = root.boundedContentX(
              userList.contentX - pixelDelta)
          } else {
            const angleDelta = Math.abs(event.angleDelta.x)
              > Math.abs(event.angleDelta.y)
                ? event.angleDelta.x : event.angleDelta.y
            const direction = angleDelta > 0 ? -1 : 1
            root.scrollTo(userList.contentX + direction
              * (root.delegateWidth + root.delegateSpacing))
          }
          event.accepted = true
        }
      }
    }

    ToolButton {
      id: previousButton

      anchors.left: parent.left
      y: (root.avatarSize - height) / 2
      width: root.navigationSize
      height: root.navigationSize
      padding: 4
      focusPolicy: Qt.NoFocus
      hoverEnabled: true
      visible: userList.hasOverflow && userList.contentX > 0.5
      icon.source: root.previousIconSource
      icon.width: 24
      icon.height: 24
      icon.color: root.foregroundColor
      display: AbstractButton.IconOnly
      onClicked: root.scrollPage(-1)

      background: Rectangle {
        radius: 4
        color: previousButton.down ? "#38000000"
          : previousButton.hovered ? "#24000000" : "transparent"
      }

      HoverHandler {
        cursorShape: Qt.PointingHandCursor
      }
    }

    ToolButton {
      id: nextButton

      anchors.right: parent.right
      y: (root.avatarSize - height) / 2
      width: root.navigationSize
      height: root.navigationSize
      padding: 4
      focusPolicy: Qt.NoFocus
      hoverEnabled: true
      visible: userList.hasOverflow
        && userList.contentX < userList.maximumContentX - 0.5
      icon.source: root.nextIconSource
      icon.width: 24
      icon.height: 24
      icon.color: root.foregroundColor
      display: AbstractButton.IconOnly
      onClicked: root.scrollPage(1)

      background: Rectangle {
        radius: 4
        color: nextButton.down ? "#38000000"
          : nextButton.hovered ? "#24000000" : "transparent"
      }

      HoverHandler {
        cursorShape: Qt.PointingHandCursor
      }
    }

    NumberAnimation {
      id: contentAnimation

      target: userList
      property: "contentX"
      duration: 180
      easing.type: Easing.OutCubic
    }
  }

  Text {
    id: notListedAction

    anchors.top: carousel.bottom
    anchors.topMargin: 2
    anchors.horizontalCenter: parent.horizontalCenter
    visible: root.showNotListed
    text: root.notListedText
    color: root.foregroundColor
    opacity: notListedHover.hovered ? 1.0 : 0.78
    font.pixelSize: 13
    font.weight: Font.Normal
    renderType: Text.NativeRendering

    TapHandler {
      onTapped: root.notListedRequested()
    }

    HoverHandler {
      id: notListedHover
      cursorShape: Qt.PointingHandCursor
    }
  }
}
