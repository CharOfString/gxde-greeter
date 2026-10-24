// Copyright (C) 2026 CharOfString <root@charofstring.cc>
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, version 3.

import QtQuick
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings

// Kept in its own file so MainWindow can load it through a Loader and keep
// working when QtQuick.VirtualKeyboard is not installed.
InputPanel {
  // Only user names and passwords are typed here: the greeter's own
  // English-only layouts (res/vkb-style/layouts) and plain key-to-character
  // input, without input methods, word prediction or handwriting.
  Component.onCompleted: {
    VirtualKeyboardSettings.defaultInputMethodDisabled = true
    VirtualKeyboardSettings.handwritingModeDisabled = true
    VirtualKeyboardSettings.layoutPath = "qrc:/gxde-vkb/layouts"
  }
}
