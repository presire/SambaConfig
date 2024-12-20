#ifndef SAMBACONFIGREADER_H
#define SAMBACONFIGREADER_H

#include <QObject>
#include <QVariantMap>
#include <QFuture>


class SambaConfigReader : public QObject
{
    Q_OBJECT

private:    // Variables
    QString m_smbPorts;

public:     // Variables

private:    // Methods
    SambaConfigReader(QObject *parent = nullptr);
    ~SambaConfigReader();
    SambaConfigReader(const SambaConfigReader&)            = delete;
    SambaConfigReader& operator=(const SambaConfigReader&) = delete;

    QVariantMap  parseGlobalSection(const QStringList &lines, int &currentLine);
    QVariantMap  parseHomesSection(const QStringList &lines, int &currentLine);
    QVariantMap  parsePrintersSection(const QStringList &lines, int &currentLine);
    QVariantMap  parseCustomSection(const QStringList &lines, int &currentLine);
    QString      extractValue(const QString &line)      const;
    QVariantList extractPortsList(const QString &line)  const;
    bool         isCommentLine(const QString &line)     const;

public:     // Methods
    static SambaConfigReader& getInstance();
    Q_INVOKABLE void loadConfig(const QString &filePath);

signals:
    void configLoaded(const QVariantList &sections);
    void errorOccurred(const QString &error);
};

#endif // SAMBACONFIGREADER_H
