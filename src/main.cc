/*
 * Copyright (C) CharOfString <root@charofstring.cc>
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */


#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QVariantMap>

int main(int argc, char* argv[]) {
  QGuiApplication app(argc, argv);

  QQmlApplicationEngine engine;
  QVariantMap init_prop;
  init_prop.insert("backgroundUri",
    QUrl("qrc:/img/example-wallpaper.png"));
  engine.setInitialProperties(init_prop);

  QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
      &app, []() {
    QCoreApplication::exit(-1);
  }, Qt::QueuedConnection);

  engine.loadFromModule("Greeter", "MainWindow");
  return app.exec();
}
