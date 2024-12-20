#ifndef SAMBASERVICE_H
#define SAMBASERVICE_H

#include <QObject>
#include <QtConcurrent>
#include <QtDBus>


// This class is used to start and stop the Systemd service unit of Samba / NMB.
class SambaService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool bSambaService READ bSambaService WRITE setSambaService NOTIFY bSambaServiceChanged)
    Q_PROPERTY(bool bNMBService READ bNMBService WRITE setNMBService NOTIFY bNMBServiceChanged)

private:    // Variables
    bool        m_bSambaService;
    bool        m_bNMBService;
    QString     m_strErrMsg;

public:     // Variables

private:    // Methods
    explicit SambaService(QObject *parent = nullptr);                           // Constructor
    SambaService(const SambaService&) = delete;                                 // Constructor
    ~SambaService();                                                            // Destructor
    int     getServiceName(const QString &name, QString &serviceName);          // Check if Samba Service file
    int     checkSystemdService(const QString &distinguished);

    QString getActiveState(const QString &ServiceName);

public:     // Methods
    static SambaService& getInstance();

    // Execute samba daemon with D-Bus.
    Q_INVOKABLE int setSystemdService(const QString &distinguished,
                                      const QString &propertyName);

    Q_INVOKABLE void checkSystemdServiceAsync(const QString &distinguished);

    Q_INVOKABLE int  checkSystemdServiceSync(const QString &distinguished);

    // Get error message.
    Q_INVOKABLE QString     getErrorMessage();

    bool bSambaService() const;
    void setSambaService(bool value);
    bool bNMBService() const;
    void setNMBService(bool value);

private slots:
    void onCheckComplete(int result, QString distinguished);

signals:
    void bSambaServiceChanged();
    void bNMBServiceChanged();
};

#endif // SAMBASERVICE_H
