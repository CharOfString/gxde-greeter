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

  width: 640
  height: 480
  visible: true
  title: "GXDM Greeter"

  Image {
    anchors.fill: parent
    source: root.backgroundUri
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: false
    visible: root.backgroundUri.toString() !== ""
  }
}
