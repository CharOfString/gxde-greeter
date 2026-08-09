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

#include "utils/macros.h"

#include <QFile>
#include <QGuiApplication>
#include <QHash>
#include <QQmlApplicationEngine>
#include <QStringList>
#include <QUrl>
#include <QVariantMap>

namespace {

using ReleaseData = QHash<QString, QString>;

ReleaseData readReleaseData(const QString& path) {
  QFile file(path);
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
    return {};
  }

  ReleaseData data;
  QString section;

  while (!file.atEnd()) {
    QString line = QString::fromUtf8(file.readLine()).trimmed();
    if (line.isEmpty() || line.startsWith('#')) {
      continue;
    }

    if (line.startsWith('[') && line.endsWith(']')) {
      section = line.mid(1, line.size() - 2).trimmed();
      continue;
    }

    const qsizetype separator = line.indexOf('=');
    if (separator <= 0) {
      continue;
    }

    const QString key = line.left(separator).trimmed();
    QString value = line.mid(separator + 1).trimmed();

    if (value.size() >= 2 && ((value.front() == '"' && value.back() == '"') || (
        value.front() == '\'' && value.back() == '\''))) {
      value = value.mid(1, value.size() - 2);
    }

    data.insert(section.isEmpty() ? key : section + '/' + key, value);
  }

  return data;
}

struct GxdeReleaseInfo {
  bool isGxde = false;
  QString label;
};

QString localizedGxdeCodename(const QString& codename) {
  if (codename.compare(GXDE15_STABLE_CODENAME,
      Qt::CaseInsensitive) == 0) {
    return QString::fromUtf8(GXDE15_STABLE_CODENAME_CN);
  }

  if (codename.compare(GXDE25_STABLE_CODENAME,
      Qt::CaseInsensitive) == 0) {
    return QString::fromUtf8(GXDE25_STABLE_CODENAME_CN);
  }

  if (codename.compare(GXDE25_UNSTABLE_CODENAME,
      Qt::CaseInsensitive) == 0) {
    return QString::fromUtf8(GXDE25_UNSTABLE_CODENAME_CN);
  }

  if (codename.compare(GXDE25_LOONGARCH_UNSTABLE_CODENAME,
      Qt::CaseInsensitive) == 0) {
    return QString::fromUtf8(GXDE25_LOONGARCH_UNSTABLE_CODENAME_CN);
  }

  return codename;
}

GxdeReleaseInfo detectGxdeRelease() {
  const ReleaseData osRelease = readReleaseData("/etc/os-release");
  GxdeReleaseInfo info;
  info.isGxde = osRelease.value("ID").compare("GXDE",
    Qt::CaseInsensitive) == 0;

  if (!info.isGxde) {
    return info;
  }

  const ReleaseData desktopVersion = readReleaseData(
    "/usr/lib/deepin/desktop-version");
  QString version = desktopVersion.value("Release/Version");
  if (version.isEmpty()) {
    version = osRelease.value("VERSION_ID");
  }

  const QString productType = desktopVersion.value("Release/Type[zh_CN]");
  const QString milestone = localizedGxdeCodename(
    desktopVersion.value("Addition/Milestone"));
  QStringList labelParts;

  for (const QString& part : {version, productType}) {
    if (!part.isEmpty()) {
      labelParts.append(part);
    }
  }

  info.label = labelParts.join(' ');
  if (!milestone.isEmpty()) {
    info.label += QString::fromUtf8(GXDE_QUOTE_BEGIN_CN)
      + milestone
      + QString::fromUtf8(GXDE_QUOTE_END_CN);
  }
  return info;
}

}  // namespace

int main(int argc, char* argv[]) {
  QGuiApplication app(argc, argv);

  QQmlApplicationEngine engine;
  const GxdeReleaseInfo gxdeRelease = detectGxdeRelease();
  QVariantMap init_prop;
  init_prop.insert("backgroundUri",
    QUrl("qrc:/img/example-wallpaper-deepin.jpg"));
  init_prop.insert("isGxdeOs", gxdeRelease.isGxde);
  init_prop.insert("gxdeReleaseLabel", gxdeRelease.label);
  engine.setInitialProperties(init_prop);

  QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
      &app, []() {
    QCoreApplication::exit(-1);
  }, Qt::QueuedConnection);

  engine.loadFromModule("Greeter", "MainWindow");
  return app.exec();
}
