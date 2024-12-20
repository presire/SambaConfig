#ifndef APPLICATIONSTATE_H
#define APPLICATIONSTATE_H

#include <QCoreApplication>
#include <QObject>
#include <QQmlEngine>
#include <QSettings>
#include <QProcess>
#include <QException>
#include <QDir>
#include <QFile>


class ApplicationState : public QObject
{
    Q_OBJECT
    // QML_ELEMENT
    // QML_SINGLETON

private:    // Variables
    QString         m_strIniFilePath;
    QString         m_UserName;
    QString         m_HomePath;
    QString         m_strErrMsg;

public:     // Variables

private:    // Methods
    ApplicationState();
    ~ApplicationState();
    ApplicationState(const ApplicationState&) = delete;
    ApplicationState& operator=(const ApplicationState&) = delete;

public:     // Methods
    static ApplicationState& getInstance();

    // Settings for SambaConfig application.
    Q_INVOKABLE int         getMainWindowX();
    Q_INVOKABLE int         getMainWindowY();
    Q_INVOKABLE int         getMainWindowWidth();
    Q_INVOKABLE int         getMainWindowHeight();
    Q_INVOKABLE bool        getMainWindowMaximized();
    Q_INVOKABLE int         setMainWindowState(int X, int Y, int Width, int Height, bool Maximized);
    Q_INVOKABLE static bool getColorMode();
    Q_INVOKABLE int         setColorMode(bool bDarkMode);
    Q_INVOKABLE int         getColorModeOverWrite();
    Q_INVOKABLE int         setColorModeOverWrite(bool bOverWrite);
    Q_INVOKABLE int         getFontSize();
    Q_INVOKABLE int         setFontSize(int FontSize);
    Q_INVOKABLE bool        getServerMode();
    Q_INVOKABLE int         setServerMode(bool bServerMode);
    Q_INVOKABLE bool        getAdminPassword();
    Q_INVOKABLE int         setAdminPassword(bool bAdminPassword);
    Q_INVOKABLE static int  getLanguage();
    Q_INVOKABLE int         setLanguage(int iLang);
    Q_INVOKABLE bool        getFirstSystemd();
    Q_INVOKABLE int         setFirstSystemd(bool bFirstSystemd);

    // Samba Config.
    Q_INVOKABLE QString     getSambaConfigFile();
    Q_INVOKABLE int         setSambaConfigFile(const QString &SambaFilePath);

    // Samba Test.
    Q_INVOKABLE QString     getSambaTestFile();
    Q_INVOKABLE int         setSambaTestFile(const QString &SambaFilePath);

    // Connect to remote server.
    Q_INVOKABLE QString     getUserName();
    Q_INVOKABLE QString     getHostName();
    Q_INVOKABLE QString     getPort();
    Q_INVOKABLE bool        getPubkeyAuth();
    Q_INVOKABLE QString     getIdentityFile();
    Q_INVOKABLE bool        getPassphrase();
    Q_INVOKABLE int         setRemoteInfo(const QString User, const QString Host, const QString Port, const QString IdentityFile,
                                          bool bPubKeyAuth, bool bPassphrase);

    // TCP/SSL connect to remote server.
    Q_INVOKABLE bool        getSSL();
    Q_INVOKABLE bool        getCert();
    Q_INVOKABLE QString     getCertFile();
    Q_INVOKABLE bool        getPrivateKey();
    Q_INVOKABLE QString     getPrivateKeyFile();
    Q_INVOKABLE int         saveRemoteInfo(QString strHostName, QString strPort,     bool bUseSSL,          bool bUseCert,
                                           QString strCertFile, bool bUsePrivateKey, QString strPrivateKey, bool bUsePassphrase);

    // Restart application.
    Q_INVOKABLE void        restartSoftware();

    // Get SambaConfig application's version.
    Q_INVOKABLE QString     getVersion();

    // Remove temporary sshd_config, ServerOption.json files.
    Q_INVOKABLE int         removeTmpFiles() const;

    // Get error message.
    Q_INVOKABLE QString     getErrorMessage() const;

signals:

public slots:

};

#endif // APPLICATIONSTATE_H
