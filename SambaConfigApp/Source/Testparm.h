#ifndef Testparm_H
#define Testparm_H

#include <QObject>
//#include "CRemoteWindow.h"


struct UserInfo {
    QString username;
    uid_t   uid;
    uid_t   gid;
    QString fullName;
    QString homeDir;
    QString shell;

    bool isEmpty() const
    {
        return username.isEmpty() && fullName.isEmpty() &&
               homeDir.isEmpty()  && shell.isEmpty();
    }
};


class Testparm : public QObject
{
    Q_OBJECT
    // QML_ELEMENT
    // QML_SINGLETON

private:
    QString                        m_TestparmOutput;
    QString                        m_strErrMsg;
    //std::unique_ptr<CRemoteWindow> m_clsRemote;

public:

private:
    explicit Testparm(QObject *parent = nullptr);                       // Constructor
    Testparm(const Testparm&)               = delete;                   // Constructor
    Testparm& operator=(const Testparm&)    = delete;                   // Constructor
    ~Testparm();                                                        // Destructor

    // Get read permission for a file.
    int     getReadFilePermissions(const QString &FilePath);

    // Get execute permission for a file.
    int     getExecuteFilePermissions(const QString &FilePath);

    // Execute testparm command on local computer.
    int     executeTestparmCommand(const QString &TestparmComandPath,
                                   const QStringList &aryOptions,
                                   const int option);

    // Execute testparm command on local computer using D-Bus. (Send helper executable)
    int     executeTestparmCommandFromHelper(const QString &strTestparmComandPath,
                                             const QStringList &aryOptions,
                                             const int option);

    // Get information about the user running the application.
    UserInfo    getCurrentUserInfo();

public:
    static Testparm& getInstance();

    // Execute sshd command on local computer.
    Q_INVOKABLE int         executeTestparmCommand(const QString &TestparmComandPath,
                                                   const QString &SambaFilePath,
                                                   const int option);

    // Get result of sshd command from helper executable.
    Q_INVOKABLE QString     getCommandResult();

    // Download sshd_config file from remote server.
    Q_INVOKABLE int         downloadSambaConfigFile(int width, int height, bool bDark, int fontPadding);

    // Get path to sshd_config on remote server.
    Q_INVOKABLE QString     getSambaConfigFilePath();

    // Execute sshd command.
    Q_INVOKABLE int         executeRemoteTestparmCommand(QString strSSHDComandPath, QString strSSHFilePath, int option);

    // Disconnect from remote server.
    Q_INVOKABLE int         disconnectFromServer();

    // Get error message.
    Q_INVOKABLE QString     getErrorMessage();

private slots:

signals:
    void resultProcess(int status, QString strErrMsg = "");
    void downloadSambaFileFromServer(QString strSSHConfigFilePath, QString strContents);
    void readTesparmResult(int status, QString strMessage);
};

#endif // Testparm_H
