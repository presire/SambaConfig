#include "ApplicationState.h"


ApplicationState::ApplicationState()
{
    m_UserName = qgetenv("USER");
    m_HomePath = QDir::homePath();
    m_strIniFilePath = m_HomePath + QDir::separator() + ".config" + QDir::separator() + "SambaConfig" + QDir::separator() + "settings.ini";
}


ApplicationState::~ApplicationState()
{}


ApplicationState& ApplicationState::getInstance()
{
    static ApplicationState instance;
    return instance;
}


int ApplicationState::getMainWindowX()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    int iMainWindowX = 0;
    if (settings.contains("X")) {
        iMainWindowX = settings.value("X").toInt();
    }

    settings.endGroup();

    return iMainWindowX;
}


int ApplicationState::getMainWindowY()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    int iMainWindowY = 0;
    if (settings.contains("Y")) {
        iMainWindowY = settings.value("Y").toInt();
    }

    settings.endGroup();

    return iMainWindowY;
}


int ApplicationState::getMainWindowWidth()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

#ifdef PINEPHONE
    int iMainWindowWidth = 375;
#else
    int iMainWindowWidth = 1280;
#endif

    if (settings.contains("Width")) {
        iMainWindowWidth = settings.value("Width").toInt();
    }

    settings.endGroup();

    return iMainWindowWidth;
}


int ApplicationState::getMainWindowHeight()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

#ifdef PINEPHONE
    int iMainWindowHeight = 812;
#else
    int iMainWindowHeight = 960;
#endif

    if (settings.contains("Height")) {
        iMainWindowHeight = settings.value("Height").toInt();
    }

    settings.endGroup();

    return iMainWindowHeight;
}


bool ApplicationState::getMainWindowMaximized()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    int bMainWindowMaximized = false;
    if (settings.contains("Maximized")) {
        bMainWindowMaximized = settings.value("Maximized").toBool();
    }

    settings.endGroup();

    return bMainWindowMaximized;
}


int ApplicationState::setMainWindowState(int X, int Y, int Width, int Height, bool Maximized)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");
        settings.setValue("X", X);
        settings.setValue("Y", Y);
        settings.setValue("Width", Width);
        settings.setValue("Height", Height);
        if(Maximized) settings.setValue("Maximized", "true");
        else          settings.setValue("Maximized", "false");

        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


bool ApplicationState::getColorMode()
{
    auto strHomePath = QDir::homePath();
    auto strIniFilePath = strHomePath + QDir::separator() + ".config" + QDir::separator() + "SambaConfig" + QDir::separator() + "settings.ini";
    QSettings settings(strIniFilePath, QSettings::IniFormat, nullptr);

    settings.beginGroup("MainWindow");

    bool bDarkMode = false;
    if(settings.contains("DarkMode")) {
        bDarkMode = settings.value("DarkMode").toBool();
    }

    settings.endGroup();

    return bDarkMode;
}


int ApplicationState::setColorMode(bool bDarkMode)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");

        if (bDarkMode) settings.setValue("DarkMode", "true");
        else           settings.setValue("DarkMode", "false");

        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


int ApplicationState::getColorModeOverWrite()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("MainWindow");

    int ColorModeOverWrite = 0;
    if (settings.contains("ColorModeOverWrite")) {
        ColorModeOverWrite = settings.value("ColorModeOverWrite").toInt();
    }

    settings.endGroup();

    return ColorModeOverWrite;
}


int ApplicationState::setColorModeOverWrite(bool bOverWrite)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("MainWindow");

        if (bOverWrite) settings.setValue("ColorModeOverWrite", 1);
        else            settings.setValue("ColorModeOverWrite", 0);

        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


bool ApplicationState::getServerMode()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    bool bServerMode = true;
    if (settings.contains("ServerMode")) {
        bServerMode = settings.value("ServerMode").toBool();
    }

    settings.endGroup();

    return bServerMode;
}


int ApplicationState::setServerMode(bool bServerMode)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("Mode");
        bServerMode ? settings.setValue("ServerMode", "true") : settings.setValue("ServerMode", "false");
        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


bool ApplicationState::getAdminPassword()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    bool bAdminPassword = true;
    if (settings.contains("AdminPassword")) {
        bAdminPassword = settings.value("AdminPassword").toBool();
    }

    settings.endGroup();

    return bAdminPassword;
}


int ApplicationState::setAdminPassword(bool bAdminPassword)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("Mode");
        bAdminPassword ? settings.setValue("AdminPassword", "true") : settings.setValue("AdminPassword", "false");
        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


int ApplicationState::getLanguage()
{
    auto strHomePath = QDir::homePath();
    auto strIniFilePath = strHomePath + QDir::separator() + ".config" + QDir::separator() + "SambaConfig" + QDir::separator() + "settings.ini";
    QSettings settings(strIniFilePath, QSettings::IniFormat, nullptr);

    settings.beginGroup("Mode");

    bool iLang = 0;
    if (settings.contains("Language")) {
        iLang = settings.value("Language").toInt();
    }

    settings.endGroup();

    return iLang;
}


int ApplicationState::setLanguage(int iLang)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("Mode");
        settings.setValue("Language", iLang);
        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


QString ApplicationState::getSambaConfigFile()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("SambaConfig");

    QString strSambaFilePath = "";
    if (settings.contains("SambaFilePath")) {
        strSambaFilePath = settings.value("SambaFilePath").toString();
    }

    settings.endGroup();

    return strSambaFilePath;
}


int ApplicationState::setSambaConfigFile(const QString &SambaFilePath)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("SambaConfig");
        settings.setValue("SambaFilePath", SambaFilePath);

        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


QString ApplicationState::getSambaTestFile()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("SambaTest");

    QString strSambaFilePath = "";
    if (settings.contains("SambaFilePath")) {
        strSambaFilePath = settings.value("SambaFilePath").toString();
    }

    settings.endGroup();

    return strSambaFilePath;
}


int ApplicationState::setSambaTestFile(const QString &SambaFilePath)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("SambaTest");
        settings.setValue("SambaFilePath", SambaFilePath);

        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


bool ApplicationState::getPubkeyAuth()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    bool bPubkeyAuth = false;
    if(settings.contains("PubKeyAuth")) {
        bPubkeyAuth = settings.value("PubKeyAuth").toBool();
    }

    settings.endGroup();

    return bPubkeyAuth;
}


bool ApplicationState::getPassphrase()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    bool bPubkeyAuth = false;
    if (settings.contains("Passphrase")) {
        bPubkeyAuth = settings.value("Passphrase").toBool();
    }

    settings.endGroup();

    return bPubkeyAuth;
}


QString ApplicationState::getUserName()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    QString strUserName = "";
    if (settings.contains("UserName")) {
        strUserName = settings.value("UserName").toString();
    }

    settings.endGroup();

    return strUserName;
}


QString ApplicationState::getHostName()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    QString strHostName = "";
    if (settings.contains("HostName")) {
        strHostName = settings.value("HostName").toString();
    }

    settings.endGroup();

    return strHostName;
}


QString ApplicationState::getPort()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    QString strPort = "";
    if (settings.contains("Port")) {
        strPort = settings.value("Port").toString();
    }

    settings.endGroup();

    return strPort;
}


QString ApplicationState::getIdentityFile()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    QString strIdentityFile = "";
    if (settings.contains("IdentityFile")) {
        strIdentityFile = settings.value("IdentityFile").toString();
    }

    settings.endGroup();

    return strIdentityFile;
}


int ApplicationState::setRemoteInfo(const QString User, const QString Host, const QString Port, const QString IdentityFile,
                                bool bPubKeyAuth, bool bPassphrase)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("Mode");
        settings.setValue("UserName", User);
        settings.setValue("HostName", Host);
        settings.setValue("Port", Port);
        settings.setValue("IdentityFile", IdentityFile);
        bPubKeyAuth ? settings.setValue("PubKeyAuth", "true") : settings.setValue("PubKeyAuth", "false");
        bPassphrase ? settings.setValue("Passphrase", "true") : settings.setValue("Passphrase", "false");

        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


bool ApplicationState::getSSL()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    bool bSSL = false;
    if (settings.contains("SSL")) {
        bSSL = settings.value("SSL").toBool();
    }

    settings.endGroup();

    return bSSL;
}


bool ApplicationState::getCert()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    bool bCert = false;
    if (settings.contains("Cert")) {
        bCert = settings.value("Cert").toBool();
    }

    settings.endGroup();

    return bCert;
}


QString ApplicationState::getCertFile()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    QString strCertFile = "";
    if (settings.contains("CertFile")) {
        strCertFile = settings.value("CertFile").toString();
    }

    settings.endGroup();

    return strCertFile;
}


bool ApplicationState::getPrivateKey()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    bool bPrivateKey = false;
    if (settings.contains("PrivateKey")) {
        bPrivateKey = settings.value("PrivateKey").toBool();
    }

    settings.endGroup();

    return bPrivateKey;
}


QString ApplicationState::getPrivateKeyFile()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Mode");

    QString strPrivateKeyFile = "";
    if (settings.contains("PrivateKeyFile")) {
        strPrivateKeyFile = settings.value("PrivateKeyFile").toString();
    }

    settings.endGroup();

    return strPrivateKeyFile;
}


int ApplicationState::saveRemoteInfo(QString strHostName, QString strPort,     bool bUseSSL,          bool bUseCert,
                                 QString strCertFile, bool bUsePrivateKey, QString strPrivateKey, bool bUsePassphrase)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("Mode");
        settings.setValue("HostName", strHostName);
        settings.setValue("Port", strPort);
        bUseSSL  ? settings.setValue("SSL", "true") : settings.setValue("SSL", "false");
        bUseCert ? settings.setValue("Cert", "true") : settings.setValue("Cert", "false");
        settings.setValue("CertFile", strCertFile);
        bUsePrivateKey ? settings.setValue("PrivateKey", "true") : settings.setValue("PrivateKey", "false");
        settings.setValue("PrivateKeyFile", strPrivateKey);
        bUsePassphrase ? settings.setValue("Passphrase", "true") : settings.setValue("Passphrase", "false");

        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


int ApplicationState::getFontSize()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Font");

    int iFontSize = 1;
    if (settings.contains("Size")) {
        iFontSize = settings.value("Size").toInt();
    }

    settings.endGroup();

    return iFontSize;
}


int ApplicationState::setFontSize(int FontSize)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("Font");

        settings.setValue("Size", FontSize);

        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


// Whether to use Systemd to get Samba / NMB startup status at startup
bool ApplicationState::getFirstSystemd()
{
    QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

    settings.beginGroup("Systemd");

    bool bFirstSystemd = true;
    if (settings.contains("FirstSystemd")) {
        bFirstSystemd = settings.value("FirstSystemd").toBool();
    }

    settings.endGroup();

    return bFirstSystemd;
}


// Save the setting whether or not to use Systemd to get Samba / NMB startup status at startup
int ApplicationState::setFirstSystemd(bool bFirstSystemd)
{
    int iRet = 0;

    try {
        QSettings settings(m_strIniFilePath, QSettings::IniFormat, this);

        settings.beginGroup("Systemd");

        settings.setValue("FirstSystemd", bFirstSystemd);

        settings.endGroup();
    }
    catch (QException *ex) {
        iRet = -1;
    }

    return iRet;
}


// Delete temporarily files used by this software.
int ApplicationState::removeTmpFiles() const
{
    QDir strDir(m_HomePath + QDir::separator() + ".config" + QDir::separator() + "SambaConfig");
    if (strDir.exists()) {
        // If exist.
        // Delete tmp sshd_config files and tmp json files ("ServerOptions" files).
        QStringList nameFilters({"smb.conf*", "ServerOptions*.json"});
        QStringList strRemoveFiles = strDir.entryList(nameFilters, QDir::Files);
        foreach (auto RemoveFile, strRemoveFiles) {
           if (!strDir.remove(RemoveFile)) {
               // Error remove tmp files.
               return -2;
           }
        }
    }
    else {
       // Not exist directory.
       return -1;
    }

    return 0;
}


void ApplicationState::restartSoftware()
{
    QString strFilePath = QCoreApplication::applicationDirPath();
    auto strExecShell = strFilePath + QDir::separator() + QString("SambaConfig.sh");

    if (QFile::exists(strExecShell)) {
        bool success = QProcess::startDetached(strExecShell, {}, strFilePath);
        if (!success) {
            m_strErrMsg = tr("Failed to start shell script.");
        }
    }
    else {
        auto strExecBinary = strFilePath + QDir::separator() + QString("SambaConfig");
        if(QFile::exists(strExecBinary)) {
            bool success = QProcess::startDetached(strExecBinary, {}, strFilePath);
            if (!success) {
                m_strErrMsg = tr("Failed to start binary.");
            }
        }
    }
}


QString ApplicationState::getVersion()
{
    auto version = QString("%1.%2.%3").arg(PROJECT_VERSION_MAJOR).arg(PROJECT_VERSION_MINOR).arg(PROJECT_VERSION_PATCH);
    return version;
}


QString ApplicationState::getErrorMessage() const
{
    return m_strErrMsg;
}
