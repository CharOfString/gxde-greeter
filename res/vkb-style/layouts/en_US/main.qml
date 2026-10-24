// Copyright (C) 2026 CharOfString <root@charofstring.cc>
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, version 3.

import QtQuick
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Components

// Plain Latin letters for user names and passwords: no accented
// alternatives, no language or hide keys.
KeyboardLayout {
  inputMode: InputEngine.InputMode.Latin
  keyWeight: 160
  readonly property real normalKeyWidth: normalKey.width
  readonly property real functionKeyWidth:
    mapFromItem(normalKey, normalKey.width / 2, 0).x

  KeyboardRow {
    Key {
      key: Qt.Key_Q
      text: "q"
    }
    Key {
      id: normalKey
      key: Qt.Key_W
      text: "w"
    }
    Key {
      key: Qt.Key_E
      text: "e"
    }
    Key {
      key: Qt.Key_R
      text: "r"
    }
    Key {
      key: Qt.Key_T
      text: "t"
    }
    Key {
      key: Qt.Key_Y
      text: "y"
    }
    Key {
      key: Qt.Key_U
      text: "u"
    }
    Key {
      key: Qt.Key_I
      text: "i"
    }
    Key {
      key: Qt.Key_O
      text: "o"
    }
    Key {
      key: Qt.Key_P
      text: "p"
    }
  }
  KeyboardRow {
    KeyboardRow {
      Layout.preferredWidth: functionKeyWidth
      Layout.fillWidth: false
      FillerKey {}
      Key {
        key: Qt.Key_A
        text: "a"
        weight: normalKeyWidth
        Layout.fillWidth: false
      }
    }
    Key {
      key: Qt.Key_S
      text: "s"
    }
    Key {
      key: Qt.Key_D
      text: "d"
    }
    Key {
      key: Qt.Key_F
      text: "f"
    }
    Key {
      key: Qt.Key_G
      text: "g"
    }
    Key {
      key: Qt.Key_H
      text: "h"
    }
    Key {
      key: Qt.Key_J
      text: "j"
    }
    Key {
      key: Qt.Key_K
      text: "k"
    }
    KeyboardRow {
      Layout.preferredWidth: functionKeyWidth
      Layout.fillWidth: false
      Key {
        key: Qt.Key_L
        text: "l"
        weight: normalKeyWidth
        Layout.fillWidth: false
      }
      FillerKey {}
    }
  }
  KeyboardRow {
    ShiftKey {
      weight: functionKeyWidth
      Layout.fillWidth: false
    }
    Key {
      key: Qt.Key_Z
      text: "z"
    }
    Key {
      key: Qt.Key_X
      text: "x"
    }
    Key {
      key: Qt.Key_C
      text: "c"
    }
    Key {
      key: Qt.Key_V
      text: "v"
    }
    Key {
      key: Qt.Key_B
      text: "b"
    }
    Key {
      key: Qt.Key_N
      text: "n"
    }
    Key {
      key: Qt.Key_M
      text: "m"
    }
    BackspaceKey {
      weight: functionKeyWidth
      Layout.fillWidth: false
    }
  }
  KeyboardRow {
    SymbolModeKey {
      weight: functionKeyWidth
      Layout.fillWidth: false
    }
    Key {
      key: Qt.Key_Comma
      text: ","
      weight: normalKeyWidth
      Layout.fillWidth: false
    }
    SpaceKey {}
    Key {
      key: Qt.Key_Period
      text: "."
      weight: normalKeyWidth
      Layout.fillWidth: false
    }
    EnterKey {
      weight: functionKeyWidth
      Layout.fillWidth: false
    }
  }
}
