#include <QtDBus>
#include <QFuture>
#include <QtConcurrent>

#ifdef _DEBUG
#include <QDebug>
#endif

#include "FirewalldManager.h"


FirewalldManager& FirewalldManager::getInstance()
{
    static FirewalldManager instance;
    return instance;
}


FirewalldManager::FirewalldManager(QObject *parent) : QObject(parent)
{
}


void FirewalldManager::loadFirewallZones()
{
    std::ignore = QtConcurrent::run([this]() {
        QStringList zones = getFirewallZonesInternal();
        bool success      = !zones.isEmpty();

        emit zonesLoaded(success, zones, m_ErrMsg);
    });
}

QStringList FirewalldManager::getFirewallZonesInternal()
{
    QDBusConnection systemBus = QDBusConnection::systemBus();
    QDBusInterface iface("org.fedoraproject.FirewallD1",
                         "/org/fedoraproject/FirewallD1",
                         "org.fedoraproject.FirewallD1.zone",
                         systemBus);

    if (!iface.isValid()) {
        m_ErrMsg = tr("Failed to create D-Bus interface for FirewallD");
        return {};
    }

    QStringList zones;
    QDBusReply<QStringList> reply = iface.call("getZones");
    if (reply.isValid()) {
        zones = reply.value();
        m_ErrMsg.clear();
    }
    else {
        m_ErrMsg = tr("Error getting firewall zones: %1").arg(reply.error().message());
    }

    return zones;
}


void FirewalldManager::openFirewallPort(const QString &zone, int port, const QString &protocol)
{
    std::ignore = QtConcurrent::run([=]() {
        bool success = openFirewallPortInternal(zone, port, protocol);
        if (success) {
            success = reloadFirewallInternal();
            if (success) {
                m_ErrMsg = "";
                emit portOpeningFinished(success, m_ErrMsg);
                return;
            }
        }

        emit portOpeningFinished(success, m_ErrMsg);
    });
}


void FirewalldManager::openFirewallPorts(const QString &zonesString, const QVariantList &ports)
{
    std::ignore = QtConcurrent::run([=]() {
        // Split zone names separated by commas.
        QStringList zones = zonesString.split(",", Qt::SkipEmptyParts);
        if (zones.empty()) {
            emit portOpeningFinished(false, tr("Specify the zone name."));
            return;
        }

        // Process for each zone.
        auto iRet = [&]{
            bool bSuccess = false;

            for (const QString &zone : zones) {
                // Remove trailing whitespace.
                QString trimmedZone = zone.trimmed();

                // Open all ports using Firewalld.
                for (const QVariant &portData : ports) {
                    QVariantMap portMap = portData.toMap();

                    auto port     = portMap["port"].toInt();
                    auto protocol = portMap["protocol"].toString().toLower();

                    // Open each port using Firewalld.
                    bSuccess = openFirewallPortInternal(trimmedZone, port, protocol);
                    if (!bSuccess) return -1;
                }
            }

            return 0;
        }();

        if (iRet) {
            emit portOpeningFinished(false, m_ErrMsg);
            return;
        }
        else {
            auto bSuccess = reloadFirewallInternal();
            if (bSuccess) {
                m_ErrMsg = "";
                emit portOpeningFinished(true, m_ErrMsg);
                return;
            }
        }
    });

    return;
}


bool FirewalldManager::openFirewallPortInternal(const QString &zone, int port, const QString &protocol)
{
    QDBusConnection systemBus = QDBusConnection::systemBus();

    if (!systemBus.interface()->isServiceRegistered("org.fedoraproject.FirewallD1")) {
        m_ErrMsg = tr("firewalld is not installed");
        return false;
    }

    QDBusInterface iface("org.fedoraproject.FirewallD1",
                         "/org/fedoraproject/FirewallD1",
                         "org.fedoraproject.FirewallD1.zone",
                         systemBus);

    if (!iface.isValid()) {
        m_ErrMsg = tr("Failed to create D-Bus interface");
        return false;
    }

    QString portStr = QString::number(port);
    QDBusReply<void> reply = iface.call("addPort", zone, portStr, protocol, 0);

    if (reply.isValid()) {
#ifdef _DEBUG
        qDebug() << tr("Port %1 opened successfully in zone %2").arg(port).arg(zone);
#endif

        QDBusInterface ifaceReload("org.fedoraproject.FirewallD1",
                                   "/org/fedoraproject/FirewallD1",
                                   "org.fedoraproject.FirewallD1",
                                   systemBus);

        if (!ifaceReload.isValid()) {
            m_ErrMsg = tr("Failed to create D-Bus interface for reload");
            return false;
        }

        QDBusReply<void> replyReload = ifaceReload.call("runtimeToPermanent");

        if (replyReload.isValid()) {
#ifdef _DEBUG
            qDebug() << tr("Firewalld is reloaded");
#endif

            return true;
        }
        else {
            m_ErrMsg = replyReload.error().message();
            return false;
        }
    }
    else {
        QDBusError error = reply.error();
        m_ErrMsg = error.message().isEmpty() ? tr("Cancel button may have been pressed.") : error.message();

        return false;
    }
}


void FirewalldManager::closeFirewallPorts(const QString &zonesString, const QVariantList &ports)
{
    std::ignore = QtConcurrent::run([=]() {
        // Split zone names separated by commas.
        QStringList zones = zonesString.split(",", Qt::SkipEmptyParts);
        if (zones.empty()) {
            emit portClosingFinished(false, tr("Specify the zone name."));
            return;
        }

        // Process for each zone.
        auto iRet = [&]{
            bool bSuccess = false;

            for (const QString &zone : zones) {
                // Remove trailing whitespace.
                QString trimmedZone = zone.trimmed();

                // Close all ports using Firewalld.
                for (const QVariant &portData : ports) {
                    QVariantMap portMap = portData.toMap();

                    auto port     = portMap["port"].toInt();
                    auto protocol = portMap["protocol"].toString().toLower();

                    // Close each port using Firewalld.
                    bSuccess = closeFirewallPortInternal(trimmedZone, port, protocol);
                    if (!bSuccess) return -1;
                }
            }

            return 0;
        }();

        if (iRet) {
            emit portClosingFinished(false, m_ErrMsg);
            return;
        }
        else {
            auto bSuccess = reloadFirewallInternal();
            if (bSuccess) {
                m_ErrMsg = "";
                emit portClosingFinished(true, m_ErrMsg);
                return;
            }
        }
    });

    return;
}


bool FirewalldManager::closeFirewallPortInternal(const QString &zone, int port, const QString &protocol)
{
    QDBusConnection systemBus = QDBusConnection::systemBus();
    QDBusInterface iface("org.fedoraproject.FirewallD1",
                         "/org/fedoraproject/FirewallD1",
                         "org.fedoraproject.FirewallD1.zone",
                         systemBus);

    if (!iface.isValid()) {
        m_ErrMsg = tr("Failed to create D-Bus interface");
        return false;
    }

    QString portStr = QString::number(port);
    QDBusReply<void> reply = iface.call("removePort", zone, portStr, protocol);

    if (reply.isValid()) {
#ifdef _DEBUG
        qDebug() << tr("Port %1 opened successfully in zone %2").arg(port).arg(zone);
#endif

        QDBusInterface ifaceReload("org.fedoraproject.FirewallD1",
                                   "/org/fedoraproject/FirewallD1",
                                   "org.fedoraproject.FirewallD1",
                                   systemBus);

        if (!ifaceReload.isValid()) {
            m_ErrMsg = tr("Failed to create D-Bus interface for reload");
            return false;
        }

        QDBusReply<void> replyReload = ifaceReload.call("runtimeToPermanent");

        if (replyReload.isValid()) {
#ifdef _DEBUG
            qDebug() << tr("Firewalld is reloaded");
#endif

            return true;
        }
        else {
            m_ErrMsg = replyReload.error().message();
            return false;
        }
    }
    else {
        QDBusError error = reply.error();
        m_ErrMsg = error.message().isEmpty() ? tr("Cancel button may have been pressed.") : error.message();

        return false;
    }
}


bool FirewalldManager::reloadFirewallInternal()
{
    QDBusConnection systemBus = QDBusConnection::systemBus();
    QDBusInterface iface("org.fedoraproject.FirewallD1",
                         "/org/fedoraproject/FirewallD1",
                         "org.fedoraproject.FirewallD1",
                         systemBus);

    if (!iface.isValid()) {
        m_ErrMsg = tr("Failed to create D-Bus interface");
        return false;
    }

    QDBusReply<void> reply = iface.call("reload");

    if (!reply.isValid()) {
        m_ErrMsg = tr("Failed to reload firewall:") + "\n" + reply.error().message();
        return false;
    }

#ifdef _DEBUG
    qDebug() << tr("Firewall configuration reloaded successfully");
#endif

    return true;
}
