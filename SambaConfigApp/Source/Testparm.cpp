#include <QtDBus>
#include <QFile>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>
#include "Testparm.h"


Testparm::Testparm(QObject *parent) : QObject(parent)
{
}


Testparm::~Testparm()
{
}


Testparm& Testparm::getInstance()
{
    static Testparm instance;
    return instance;
}


// Get read file permission.
int Testparm::getReadFilePermissions(const QString &FilePath)
{
    QFileInfo FileInfo(FilePath);

    if (FileInfo.exists()) {
        // Get running software user name and group ID.
        UserInfo currentUserInfo;
        try {
            currentUserInfo = getCurrentUserInfo();
        }
        catch (const std::exception &e) {
            // Failed to get user information.
            m_strErrMsg = tr("Error: ") + e.what();
            return -2;
        }

        auto permission = FileInfo.permissions();
        if (currentUserInfo.username == FileInfo.owner())
        {   // If the owner of the sshd_config file and the user running this executable are the same
            if ((permission & QFileDevice::Permission::ReadUser) == QFileDevice::Permission::ReadUser) {
                // If the executing user has read permission to the smb.conf file
                return 0;
            }
        }
        else if (currentUserInfo.gid == FileInfo.groupId())
        {   // If the group of the sshd_config file and the user's group running this executable are the same
            if ((permission & QFileDevice::Permission::ReadGroup) == QFileDevice::Permission::ReadGroup) {
                // If the executing user has read permission to the smb.conf file
                return 0;
            }
        }
        else {
            if ((permission & QFileDevice::Permission::ReadOther) == QFileDevice::Permission::ReadOther) {
                // If the executing user has read permission to the smb.conf file
                return 0;
            }
        }
    }
    else {
        // If the file does not exist.
        m_strErrMsg = tr("No such file : %1.").arg(FilePath);
        return -2;
    }

    // If you do not have read permission.
    return -1;
}


// Get execute file permission.
int Testparm::getExecuteFilePermissions(const QString &FilePath)
{
    QFileInfo FileInfo(FilePath);

    if (FileInfo.exists()) {
        // Get running software user name and group ID.
        UserInfo currentUserInfo;
        try {
            currentUserInfo = getCurrentUserInfo();
        }
        catch (const std::exception &e) {
            // Failed to get user information.
            m_strErrMsg = tr("Error: ") + e.what();
            return -2;
        }

        auto permission = FileInfo.permissions();
        if (currentUserInfo.username == FileInfo.owner()) {
            // If the owner of the sshd_config file and the user running this executable are the same
            if ((permission & QFileDevice::Permission::ExeUser) == QFileDevice::Permission::ExeUser) {
                // If the executing user has read permission to the smb.conf file
                return 0;
            }
        }
        else if (currentUserInfo.gid == FileInfo.groupId()) {
            // If the group of the sshd_config file and the user's group running this executable are the same
            if ((permission & QFileDevice::Permission::ExeGroup) == QFileDevice::Permission::ExeGroup) {
                // If the executing user has read permission to the smb.conf file
                return 0;
            }
        }
        else {
            if ((permission & QFileDevice::Permission::ExeOther) == QFileDevice::Permission::ExeOther) {
                // If the executing user has read permission to the smb.conf file
                return 0;
            }
        }
    }
    else {
        // If the file does not exist.
        m_strErrMsg = tr("No such file : %1.").arg(FilePath);
        return -2;
    }

    // If you do not have read permission.
    return -1;
}


// Get information about the user running the application.
UserInfo Testparm::getCurrentUserInfo()
{
    UserInfo currentUser;

    uid_t uid = getuid();
    gid_t gid = getgid();

    struct passwd *pw = getpwuid(uid);

    if (pw != nullptr) {
        currentUser.username    = QString::fromLocal8Bit(pw->pw_name);
        currentUser.uid         = uid;
        currentUser.gid         = gid;
        currentUser.fullName    = QString::fromLocal8Bit(pw->pw_gecos);
        currentUser.homeDir     = QString::fromLocal8Bit(pw->pw_dir);
        currentUser.shell       = QString::fromLocal8Bit(pw->pw_shell);
    }

    if (currentUser.isEmpty()) {
        throw std::runtime_error(tr("Failed to retrieve user information.").toStdString());
    }

    return currentUser;
}


// Execute testparm command on local computer.
int Testparm::executeTestparmCommand(const QString &TestparmComandPath, const QString &SambaFilePath, const int option)
{
    QStringList aryOptions = {};
    switch (option) {
    case 0:
        aryOptions.append({"-s", SambaFilePath});
        break;
    case 1:
        aryOptions.append({"-v", SambaFilePath});
        break;
    case 2:
        aryOptions.append({"--show-all-parameters", SambaFilePath});
        break;
    default:
        aryOptions.append({"-s", SambaFilePath});
        break;
    }

    // Check execution authority of the testparm command.
    auto iRet = getExecuteFilePermissions(TestparmComandPath);
    if (iRet == 0) {
        // Check read authority of the smb.conf.
        iRet = getReadFilePermissions(SambaFilePath);

        if (iRet == 0) {
            iRet = executeTestparmCommand(TestparmComandPath, aryOptions, option);
        }
        else if (iRet == -1) {
            // Execute testparm command with administrative privileges.
            if (executeTestparmCommandFromHelper(TestparmComandPath, aryOptions, option)) {
                return -1;
            }
        }
        else if (iRet == -2) {
            // Not exist smb.conf file.
            return iRet;
        }
    }
    else if (iRet == -1) {
        // Execute testparm command with administrative privileges.
        if (executeTestparmCommandFromHelper(TestparmComandPath, aryOptions, option)) {
            return -1;
        }
    }
    else if (iRet == -2) {
        // Not exist testparm command.
        return iRet;
    }

    return iRet;
}


// Execute testparm command on local computer.
int Testparm::executeTestparmCommand(const QString &TestparmComandPath, const QStringList &aryOptions, const int option)
{
    QString strStdMsg = "",
            strErrMsg = "";

    // Check mode.
    bool bTestOption    = false,
         bVerboseOption = false;
    foreach(const auto &option, aryOptions) {
        static const QRegularExpression RegExTest("-s");
        QRegularExpressionMatch matchTest = RegExTest.match(option);
        if(matchTest.hasMatch()) {
            // If testparm command is test mode.
            bTestOption = true;
        }

        static const QRegularExpression RegExVerbose("-v");
        QRegularExpressionMatch matchVerbose = RegExVerbose.match(option);
        if(matchVerbose.hasMatch()) {
            // If testparm command is verbose mode.
            bVerboseOption = true;
        }
    }

    // Execute testparm command, and then get output.
    QProcess Process;
    QObject::connect(&Process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
                     [&Process, &strStdMsg, &strErrMsg, bTestOption]([[maybe_unused]] int exitCode, [[maybe_unused]] QProcess::ExitStatus exitStatus) {
                         strStdMsg  = QString::fromLocal8Bit(Process.readAllStandardError());
                         strStdMsg += QString::fromLocal8Bit(Process.readAllStandardOutput());

                         if(bTestOption && strStdMsg.isEmpty()) {
                             strStdMsg = tr("Success.") + QString("\n") + tr("There is nothing wrong with smb.conf file.");
                         }
                     });

    // Start process.
    Process.start(TestparmComandPath, aryOptions);

    // Once the process starts, send [Enter] key.
    if (bVerboseOption && Process.waitForStarted()) {
        Process.write("\n");
    }

    // Wait for process.
    Process.waitForFinished();

    // Get standard-output message.
    m_TestparmOutput = strStdMsg;

    return 0;
}


// Execute testparm command on local computer using D-Bus. (Send helper executable)
int Testparm::executeTestparmCommandFromHelper(const QString &TestparmComandPath, const QStringList &aryOptions, const int option)
{
    // Execute testparm command with administrative privileges.
    QDBusConnection bus = QDBusConnection::systemBus();

    if (!bus.isConnected()) {
        m_strErrMsg = tr("Cannot connect to the D-Bus system bus.");
        return -1;
    }

    // this is our Special Action that after allowed will call the helper
    QDBusMessage message = QDBusMessage::createMethodCall("org.presire.sambaconfig",
                                                          "/org/presire/sambaconfig",
                                                          "org.presire.sambaconfig.server",
                                                          QLatin1String("ExecuteTestparm"));

    // If a method in a helper file has arguments, enter the arguments.
    QList<QVariant> ArgsToHelper;
    ArgsToHelper << QVariant::fromValue(TestparmComandPath) << QVariant::fromValue(aryOptions);
    message.setArguments(ArgsToHelper);

    // Send a message to DBus. (Execute the helper file.)
    QDBusMessage reply = bus.call(message);

    // Receive the return value (including arguments) from the helper file.
    // The methods in the helper file have two arguments, so check them.
    if (reply.type() == QDBusMessage::ReplyMessage) {
        // Get return value from return parameter
        // the reply can be anything, here receive values.
        if (reply.arguments().at(0).toInt() == -1) {
            // If the helper file method fails after successful authentication
            m_strErrMsg = reply.arguments().at(2).toString();
            return -1;
        }
        else if (reply.arguments().at(0).toInt() == 1) {
            // Cancel authentication.
            return 1;
        }

        // the reply can be anything, receive an Array (Out : a(sus)).
        // At this time, use QDBusArgument.

        //QDBusArgument argsReadContents = reply.arguments().at(1).value<QDBusArgument>();
        // <構造体名> strtReadContents;
        //reply.arguments().at(1).value<QDBusArgument>() >> strtReadContents;
        if (reply.arguments().at(0).toInt() == 0 && option == 0) {
            // Success testparm command with test mode.
            m_TestparmOutput = tr("Success.") + QString("\n") + tr("There is nothing wrong with smb.conf file.");
        }
        else {
            // Success testparm command without test mode.
            m_TestparmOutput = reply.arguments().at(2).toString() + reply.arguments().at(1).toString();
        }
    }
    else if (reply.type() == QDBusMessage::MethodCallMessage) {
        m_strErrMsg = tr("Message did not receive a reply. (timeout by message bus)");
        return -1;
    }
    else if (reply.type() == QDBusMessage::ErrorMessage) {
        m_strErrMsg = tr("Could not send message to D-Bus.");
        return -1;
    }

    return 0;
}


// Get result of testparm command from helper executable.
QString Testparm::getCommandResult()
{
    return m_TestparmOutput;
}


// Download smb.conf file from remote server.
int Testparm::downloadSambaConfigFile(int width, int height, bool bDark, int fontPadding)
{
//    if(m_clsRemote == nullptr)
//    {
//        m_clsRemote = std::make_unique<CRemoteWindow>(this);
//        QObject::connect(m_clsRemote.get(), &CRemoteWindow::downloadSambaFile, this, &Testparm::downloadSambaFileFromServer);
//        QObject::connect(m_clsRemote.get(), &CRemoteWindow::sendTestparmResult,  this, &Testparm::readTestparmResult);
//    }

//    m_clsRemote->GetSambaConfigFile(width * 0.6, height * 0.6, bDark, fontPadding);

    return 0;
}


// Get path to smb.conf on remote server.
QString Testparm::getSambaConfigFilePath()
{
//    if (m_clsRemote != nullptr) {
//        return m_clsRemote->GetRemoteSambaFile();
//    }

    return "";
}


// Execute testparm command.
int Testparm::executeRemoteTestparmCommand(QString TestparmComandPath, QString RemoteFilePath, int option)
{
//    QStringList aryOptions = {};
//    switch (option) {
//        case 0:
//            aryOptions.append({"-s", RemoteFilePath});
//            break;
//        case 1:
//            aryOptions.append({"-v", RemoteFilePath});
//            break;
//        case 2:
//            aryOptions.append({"--show-all-parameters", RemoteFilePath});
//            break;
//        default:
//            aryOptions.append({"s", RemoteFilePath});
//            break;
//    }

//    auto ExecuteCommand = QString("testparm") + QString("\\\\//") + TestparmComandPath + QString("\\\\//") + aryOptions.join("\\\\//");

//    if (m_clsRemote == nullptr) {
//        m_strErrMsg = tr("No instance libRemoteWindow library.") + "<br>" +
//                        tr("You may not have selected \"smb.conf\" file on remote server.");
//        return -1;
//    }

//    auto iRet = m_clsRemote->ExecRemoteTestparmCommand(ExecuteCommand);
//    if (iRet != 0) {
//        m_strErrMsg = m_clsRemote->GetErrorMessage();

//        return -1;
//    }

    return 0;
}


// Disconnect from remote server.
int Testparm::disconnectFromServer()
{
//    if (m_clsRemote == nullptr) {
//        m_strErrMsg = tr("No instance libRemoteWindow library.") + "<br>" +
//                        tr("You may not have selected \"smb.conf\" file on remote server.");
//        return -1;
//    }

//    m_clsRemote->DisconnectFromServer();

    return 0;
}


// Get error message.
QString Testparm::getErrorMessage()
{
    return m_strErrMsg;
}
