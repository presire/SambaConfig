#ifndef FIREWALLMANAGER_H
#define FIREWALLMANAGER_H


#include <QObject>


class FirewalldManager : public QObject
{
    Q_OBJECT

private:    // Variables
    QString m_ErrMsg;

public:     // Variables

private:    // Methods
    FirewalldManager(QObject *parent = nullptr);
    FirewalldManager(const FirewalldManager&)            = delete;
    FirewalldManager& operator=(const FirewalldManager&) = delete;

    QStringList getFirewallZonesInternal();                                 // Helper function to get firewall zones
    bool        openFirewallPortInternal(const QString &zone,               // Open firewalld ports
                                         int port,
                                         const QString &protocol);
    bool        closeFirewallPortInternal(const QString &zone,              // Open firewalld ports
                                  int port,
                                  const QString &protocol);
    bool        reloadFirewallInternal();                                   // Reload firewalld

public:    // Methods
    static FirewalldManager& getInstance();

    Q_INVOKABLE void loadFirewallZones();                                   // Helper function to get firewall zones
    Q_INVOKABLE void openFirewallPort(const QString &zone,                  // Open firewalld port
                                      int port,
                                      const QString &protocol = "tcp");
    Q_INVOKABLE void openFirewallPorts(const QString &zonesString,          // Open firewalld ports
                                       const QVariantList &ports);
    Q_INVOKABLE void closeFirewallPorts(const QString &zonesString,         // Open firewalld ports
                                        const QVariantList &ports);

signals:
    void zonesLoaded(bool success,
                     const QStringList &zones,
                     const QString &errorMessage);
    void portOpeningFinished(bool success,
                             const QString &errorMessage);
    void portClosingFinished(bool success,
                             const QString &errorMessage);
};


#endif  // FIREWALLMANAGER_H
