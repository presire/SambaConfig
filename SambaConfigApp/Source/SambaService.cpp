#include <QtDBus>
#include <QFile>
#include "SambaService.h"


SambaService::SambaService(QObject *parent) : m_bSambaService(false), m_bNMBService(false), QObject{parent}
{
}


SambaService::~SambaService()
{
}


// Returns an instance of itself.
SambaService& SambaService::getInstance()
{
    static SambaService instance;
    return instance;
}


// Start the Systemd service.
int SambaService::setSystemdService(const QString &distinguished, const QString &propertyName)
{
    // Check service name.
    QString ServiceName = "";
    if (getServiceName(distinguished, ServiceName)) {
        return -1;
    }

    // Establish connection to D-Bus system bus.
    QDBusConnection bus = QDBusConnection::systemBus();

    if (!bus.isConnected()) {
        m_strErrMsg = tr("Cannot connect to the D-Bus system bus.");
        return 1;
    }

    // Create D-Bus interface.
    QDBusInterface interface("org.freedesktop.systemd1",
                             "/org/freedesktop/systemd1",
                             "org.freedesktop.systemd1.Manager",
                             bus);

    if (!interface.isValid()) {
        m_strErrMsg = tr("Failed to create D-Bus interface: %1").arg(interface.lastError().message());
        return 1;
    }

    // Start smb / nmb service.
    QDBusReply<QDBusObjectPath> replyStart = interface.call(propertyName, ServiceName, "replace");

    if (replyStart.isValid()) {
        // If the service is started successfully
    }
    else {
        // If the service fails to start
        QDBusError error = replyStart.error();
        if (error.type() == QDBusError::AccessDenied) {
            m_strErrMsg = tr("Authentication canceled or insufficient authorization.");
            // Here, you can prompt the user to retry or do something else
            return 1;
        }
        else {
            m_strErrMsg = tr("Service failed to start: %1").arg(error.message());
            return -1;
        }
    }

    return 0;
}


// Check the status of the Systemd service. (asynchronous)
void SambaService::checkSystemdServiceAsync(const QString &distinguished)
{
    [[maybe_unused]] auto future = QtConcurrent::run([this, distinguished]() {
        int result = this->checkSystemdService(distinguished);
        QMetaObject::invokeMethod(this, "onCheckComplete", Qt::QueuedConnection, Q_ARG(int, result), Q_ARG(QString, distinguished));
    });
}


// Check the status of the Systemd service.
int SambaService::checkSystemdService(const QString &distinguished)
{
    // Check service name.
    QString ServiceName = "";
    if (getServiceName(distinguished, ServiceName)) {
        return -1;
    }

    // Establish connection to D-Bus system bus.
    QDBusConnection bus = QDBusConnection::systemBus();
    if (!bus.isConnected()) {
        m_strErrMsg = tr("Cannot connect to the D-Bus system bus.");
        return -1;
    }

    QEventLoop loop;
    QTimer timer;

    // Obtain daemon status at 1 second intervals.
    timer.setInterval(1000);

    connect(&timer, &QTimer::timeout, &loop, [&]() {
        QString activeState = getActiveState(ServiceName);
        if (activeState.compare("activating", Qt::CaseSensitive) != 0) {
            // End of check
            loop.quit();
        }
    });

    timer.start();
    loop.exec();

    // Check final condition.
    QString finalState = getActiveState(ServiceName);
    auto iRet = finalState.compare("active", Qt::CaseSensitive) == 0 ? 1 : 0;

    return iRet;
}


// Check the status of the Systemd service. (synchronous)
int SambaService::checkSystemdServiceSync(const QString &distinguished)
{
    // Check service name.
    QString ServiceName = "";
    if (getServiceName(distinguished, ServiceName)) {
        return -1;
    }

    // Establish connection to D-Bus system bus.
    QDBusConnection bus = QDBusConnection::systemBus();
    if (!bus.isConnected()) {
        m_strErrMsg = tr("Cannot connect to the D-Bus system bus.");
        return -1;
    }

    // Create a message calling the GetUnit method of org.freedesktop.systemd1.Manager.
    QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                          "/org/freedesktop/systemd1",
                                                          "org.freedesktop.systemd1.Manager",
                                                          "GetUnit");

    // Add service name as an argument to D-Bus messages.
    message << ServiceName;

    // Send D-Bus messages and get results synchronously.
    QDBusMessage reply = QDBusConnection::systemBus().call(message);

    if (reply.type() == QDBusMessage::ErrorMessage) {
        // Stopped service.
        return false;
    }

    // Get unit path.
    QString unitPath = reply.arguments().at(0).value<QDBusObjectPath>().path();

    // Create a message calling the Get method of org.freedesktop.DBus.Properties.
    QDBusMessage propertyMessage = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                                  unitPath,
                                                                  "org.freedesktop.DBus.Properties",
                                                                  "Get");

    // Add interface name and property name as arguments to D-Bus messages.
    propertyMessage << "org.freedesktop.systemd1.Unit" << "ActiveState";

    // Send D-Bus message, and then get results synchronously.
    QDBusMessage propertyReply = QDBusConnection::systemBus().call(propertyMessage);

    if (propertyReply.type() == QDBusMessage::ErrorMessage) {
        m_strErrMsg = tr("Failed to get ActiveState property. Error: %1").arg(propertyReply.errorMessage());
        return false;
    }

    // Get property value.
    QString activeState = propertyReply.arguments().at(0).value<QDBusVariant>().variant().toString();

    // Check "active".
    return activeState.compare("active", Qt::CaseInsensitive) == 0 ? true : false;
}


// Check whether the Systemd service is in “activating” status or not.
QString SambaService::getActiveState(const QString &ServiceName)
{
    // Calling the GetUnit method. (D-Bus interface name)
    QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                          "/org/freedesktop/systemd1",
                                                          "org.freedesktop.systemd1.Manager",
                                                          "GetUnit");
    message << ServiceName;
    QDBusMessage reply = QDBusConnection::systemBus().call(message);

    if (reply.type() == QDBusMessage::ErrorMessage) {
        return "inactive";
    }

    QString unitPath = reply.arguments().at(0).value<QDBusObjectPath>().path();

    // Obtaining the ActiveState property
    QDBusMessage propertyMessage = QDBusMessage::createMethodCall("org.freedesktop.systemd1",
                                                                  unitPath,
                                                                  "org.freedesktop.DBus.Properties",
                                                                  "Get");

    propertyMessage << "org.freedesktop.systemd1.Unit" << "ActiveState";

    QDBusMessage propertyReply = QDBusConnection::systemBus().call(propertyMessage);

    if (propertyReply.type() == QDBusMessage::ErrorMessage) {
        m_strErrMsg = tr("Failed to get ActiveState property. Error: %1").arg(propertyReply.errorMessage());
        return "unknown";
    }

    return propertyReply.arguments().at(0).value<QDBusVariant>().variant().toString();
}


// Check if Service file exists
int SambaService::getServiceName(const QString &name, QString &serviceName)
{
    if (name.compare("smb", Qt::CaseSensitive) == 0) {
        if (!QFile::exists("/usr/lib/systemd/system/smbd.service") && !QFile::exists("/etc/systemd/system/smbd.service")) {
            if (!QFile::exists("/usr/lib/systemd/system/smb.service") && !QFile::exists("/etc/systemd/system/smb.service")) {
                m_strErrMsg = tr("No such file Samba Service file.") + "\n" + tr("You may need to install Samba.");
                return -1;
            }
            else {
                serviceName = "smb.service";
            }
        }
        else {
            serviceName = "smbd.service";
        }
    }
    else if (name.compare("nmb", Qt::CaseSensitive) == 0) {
        if (!QFile::exists("/usr/lib/systemd/system/nmbd.service") && !QFile::exists("/etc/systemd/system/nmbd.service")) {
            if (!QFile::exists("/usr/lib/systemd/system/nmb.service") && !QFile::exists("/etc/systemd/system/nmb.service")) {
                m_strErrMsg = tr("No such file NMB Service file.") + "\n" + tr("You may need to install NMB.");
                return -1;
            }
            else {
                serviceName = "nmb.service";
            }
        }
        else {
            serviceName = "nmbd.service";
        }
    }
    else {
        m_strErrMsg = tr("Unknown service name.");
        return -1;
    }

    return 0;
}


// Finished checking the status of Systemd service,
// signal each status of Samba / NMB.
void SambaService::onCheckComplete(int result, QString distinguished)
{
    if (distinguished.compare("smb", Qt::CaseSensitive) == 0)       setSambaService(result == 1);
    else if (distinguished.compare("nmb", Qt::CaseSensitive) == 0)  setNMBService(result == 1);
}


// Send signal status of Samba.
void SambaService::setSambaService(bool value)
{
    if (m_bSambaService != value) {
        m_bSambaService = value;
        emit bSambaServiceChanged();
    }
}


// Send signal status of NMB.
void SambaService::setNMBService(bool value)
{
    if (m_bNMBService != value) {
        m_bNMBService = value;
        emit bNMBServiceChanged();
    }
}


// Get status of Samba.
bool SambaService::bSambaService() const
{
    return m_bSambaService;
}


// Get status of NMB.
bool SambaService::bNMBService() const
{
    return m_bNMBService;
}


// Get error message.
QString SambaService::getErrorMessage()
{
    return m_strErrMsg;
}
