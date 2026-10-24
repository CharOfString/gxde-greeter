// Copyright (C) 2026 CharOfString <root@charofstring.cc>
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, version 3.

import QtQuick
import QtQuick.Effects

// Popup frame following the DTK menus of gxde-dock's V23 mode
// (frame/util/styledmenu.cpp, v23menustyle.cpp): radius 8, frosted
// translucent window color, a dark outer and a light inner hairline and a
// soft drop shadow.
Item {
  id: frame

  property bool light: false
  property Item backdrop: null
  property int radius: 8
  // Owner geometry the backdrop region depends on but cannot observe
  // (position, scale, visibility of the popup the frame belongs to).
  property var trackedGeometry: []
  readonly property int backdropPadding: 32
  readonly property color windowColor: light ? "#f8f8f8" : "#252525"
  readonly property real windowAlpha: light ? 0.45 : 0.6

  // The backdrop region behind the frame, padded so the blur has real
  // pixels to sample at the edges.
  readonly property rect backdropRect: {
    frame.trackedGeometry
    if (!frame.backdrop || width <= 0 || height <= 0) {
      return Qt.rect(0, 0, 0, 0)
    }
    return frame.mapToItem(frame.backdrop,
      -frame.backdropPadding, -frame.backdropPadding,
      width + frame.backdropPadding * 2, height + frame.backdropPadding * 2)
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
      radius: frame.radius
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
      radius: frame.radius
      antialiasing: true
    }
  }

  // Created each time the frame shows and dropped once it is hidden, so the
  // backdrop is sampled afresh before the first frame instead of a hidden,
  // kept texture showing the blur of the previous opening.
  Loader {
    active: frame.visible && frame.backdrop !== null
    sourceComponent: Item {
      ShaderEffectSource {
        id: backdropSource

        sourceItem: frame.backdrop
        sourceRect: frame.backdropRect
        visible: false
        live: true
      }

      Item {
        id: backdropMask

        width: frame.width + frame.backdropPadding * 2
        height: frame.height + frame.backdropPadding * 2
        visible: false
        layer.enabled: true

        Rectangle {
          x: frame.backdropPadding
          y: frame.backdropPadding
          width: frame.width
          height: frame.height
          radius: frame.radius
          antialiasing: true
        }
      }

      MultiEffect {
        x: -frame.backdropPadding
        y: -frame.backdropPadding
        width: backdropMask.width
        height: backdropMask.height
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
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: frame.radius
    antialiasing: true
    color: Qt.rgba(frame.windowColor.r, frame.windowColor.g,
      frame.windowColor.b, frame.backdrop ? frame.windowAlpha : 1.0)
    border.width: 1
    border.color: frame.light ? "#1f000000" : "#80000000"

    Rectangle {
      anchors.fill: parent
      anchors.margins: 1
      radius: frame.radius - 1
      antialiasing: true
      color: "transparent"
      border.width: 1
      border.color: frame.light ? "#99ffffff" : "#1affffff"
    }
  }
}
