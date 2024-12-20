#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <QtConcurrent>
#include "SambaConfigReader.h"


SambaConfigReader::SambaConfigReader(QObject *parent) : QObject(parent)
{
}


SambaConfigReader::~SambaConfigReader()
{
}


SambaConfigReader& SambaConfigReader::getInstance()
{
    static SambaConfigReader instance;
    return instance;
}


void SambaConfigReader::loadConfig(const QString &filePath)
{
    QFuture<void> future = QtConcurrent::run([this, filePath]() {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            emit errorOccurred(tr("Failed to open file: %1").arg(filePath));
            return;
        }

        QTextStream stream(&file);
        QStringList lines = stream.readAll().split('\n');
        file.close();

        QVariantList sections;
        static QRegularExpression sectionRegex(R"(\[(.*?)\])");

        for (int i = 0; i < lines.size(); ++i) {
            QString line = lines[i].trimmed();
            if (line.isEmpty() || isCommentLine(line)) continue;

            auto match = sectionRegex.match(line);
            if (match.hasMatch()) {
                QString sectionName = match.captured(1);
                QVariantMap section;
                section["name"] = sectionName;

                if (sectionName == "global") {
                    section["values"] = parseGlobalSection(lines, i);
                }
                else if (sectionName == "homes") {
                    section["values"] = parseHomesSection(lines, i);
                }
                else if (sectionName == "printers") {
                    section["values"] = parsePrintersSection(lines, i);
                }
                else {
                    section["values"] = parseCustomSection(lines, i);
                }

                sections.append(section);
            }
        }

        emit configLoaded(sections);
    });
}


QVariantMap SambaConfigReader::parseGlobalSection(const QStringList &lines, int &currentLine)
{
    QVariantMap values;
    QStringList normalKeys = {
        "workgroup",
        "map to guest",
        "passdb backend",
        "usershare allow guests"
    };

    while (++currentLine < lines.size()) {
        QString line = lines[currentLine].trimmed();
        if (line.isEmpty() || isCommentLine(line)) continue;
        if (line.startsWith("[")) {
            --currentLine;
            break;
        }

        // [global]セクション : smb portsキーの場合
        if (line.startsWith("smb ports") || line.startsWith("smb ports=")) {
            values["smb ports"] = extractPortsList(line);
            continue;
        }

        // [global]セクション : その他のキーの場合
        for (const QString &key : normalKeys) {
            if (line.startsWith(key + "=") || line.startsWith(key + " =")) {
                values[key] = extractValue(line);
                break;
            }
        }
    }

    return values;
}


QVariantList SambaConfigReader::extractPortsList(const QString &line) const
{
    QVariantList ports;
    int equalPos = line.indexOf('=');
    if (equalPos == -1) return ports;

    QString valueStr = line.mid(equalPos + 1).trimmed();
    QStringList portStrings = valueStr.split(' ', Qt::SkipEmptyParts);

    for (const QString &portStr : portStrings) {
        bool ok;
        int port = portStr.toInt(&ok);
        if (ok) {
            ports.append(port);
        }
    }

    return ports;
}


QVariantMap SambaConfigReader::parseHomesSection(const QStringList &lines, int &currentLine)
{
    QVariantMap values;
    QStringList keys = {
        "comment",
        "valid users",
        "browseable",
        "read only",
        "inherit acls"
    };

    while (++currentLine < lines.size()) {
        QString line = lines[currentLine].trimmed();
        if (line.isEmpty() || isCommentLine(line)) continue;
        if (line.startsWith("[")) {
            --currentLine;
            break;
        }

        for (const QString &key : keys) {
            if (line.startsWith(key + "=") || line.startsWith(key + " =")) {
                values[key] = extractValue(line);
                break;
            }
        }
    }
    return values;
}


QVariantMap SambaConfigReader::parsePrintersSection(const QStringList &lines, int &currentLine)
{
    QVariantMap values;
    QStringList keys = {
        "comment",
        "path",
        "printable",
        "create mask",
        "browseable"
    };

    while (++currentLine < lines.size()) {
        QString line = lines[currentLine].trimmed();
        if (line.isEmpty() || isCommentLine(line)) continue;
        if (line.startsWith("[")) {
            --currentLine;
            break;
        }

        for (const QString &key : keys) {
            if (line.startsWith(key + "=") || line.startsWith(key + " =")) {
                values[key] = extractValue(line);
                break;
            }
        }
    }

    return values;
}


QVariantMap SambaConfigReader::parseCustomSection(const QStringList &lines, int &currentLine)
{
    QVariantMap values;
    QStringList keys = {
        "comment",
        "path",
        "read only",
        "browseable",
        "guest ok",
        "create mask",
        "directory mask",
        "inherit acls",
        "store dos attributes",
        "veto files",
        "force group",
        "write list"
    };

    while (++currentLine < lines.size()) {
        QString line = lines[currentLine].trimmed();
        if (line.isEmpty() || isCommentLine(line)) continue;
        if (line.startsWith("[")) {
            --currentLine;
            break;
        }

        for (const QString &key : keys) {
            if (line.startsWith(key + "=") || line.startsWith(key + " =")) {
                values[key] = extractValue(line);
                break;
            }
        }
    }

    return values;
}


QString SambaConfigReader::extractValue(const QString &line) const
{
    int equalPos = line.indexOf('=');
    if (equalPos == -1) return QString();

    return line.mid(equalPos + 1).trimmed();
}


bool SambaConfigReader::isCommentLine(const QString &line) const
{
    return line.startsWith('#') || line.startsWith(';');
}
