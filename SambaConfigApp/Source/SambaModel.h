#ifndef SAMBAMODEL_H
#define SAMBAMODEL_H


#include <QObject>
#include <QAbstractListModel>
#include <QQmlListProperty>


class SambaItem : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString directory    READ directory   WRITE setDirectory   NOTIFY directoryChanged)
    Q_PROPERTY(QString shareName    READ shareName   WRITE setShareName   NOTIFY shareNameChanged)
    Q_PROPERTY(QString permissions  READ permissions WRITE setPermissions NOTIFY permissionsChanged)
    Q_PROPERTY(QString visibility   READ visibility  WRITE setVisibility  NOTIFY visibilityChanged)
    Q_PROPERTY(QString description  READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(bool    bAllUsers    READ bAllUsers   WRITE setbAllUsers   NOTIFY allUsersChanged)
    Q_PROPERTY(QStringList users    READ users       WRITE setUsers       NOTIFY usersChanged)
    Q_PROPERTY(QStringList ports    READ ports       WRITE setPorts       NOTIFY portsChanged)

private:    // Variables
    QString     m_directory;
    QString     m_shareName;
    QString     m_permissions;
    QString     m_visibility;
    QString     m_description;
    bool        m_bAllUsers;
    QStringList m_users;
    QStringList m_ports;

public:     // Variables

private:    // Methods

public:     // Methods
    explicit SambaItem(QObject *parent = nullptr) : QObject(parent) , m_bAllUsers(false)
    {}

    // Getter methods for the other properties
    QString     directory()   const { return m_directory; }
    QString     shareName()   const { return m_shareName; }
    QString     permissions() const { return m_permissions; }
    QString     visibility()  const { return m_visibility; }
    QString     description() const { return m_description; }
    bool        bAllUsers()   const { return m_bAllUsers; }
    QStringList users()       const { return m_users; }
    QStringList ports()       const { return m_ports; }

    // Setter methods for the other properties
    void setDirectory(const QString &directory)
    {
        if (m_directory != directory) {
            m_directory = directory;
            emit directoryChanged();
        }
    }

    void setShareName(const QString &shareName)
    {
        if (m_shareName != shareName) {
            m_shareName = shareName;
            emit shareNameChanged();
        }
    }

    void setPermissions(const QString &permissions)
    {
        if (m_permissions != permissions) {
            m_permissions = permissions;
            emit permissionsChanged();
        }
    }

    void setVisibility(const QString &visibility)
    {
        if (m_visibility != visibility) {
            m_visibility = visibility;
            emit visibilityChanged();
        }
    }

    void setDescription(const QString &description)
    {
        if (m_description != description) {
            m_description = description;
            emit descriptionChanged();
        }
    }

    void setbAllUsers(bool allUsers)
    {
        if (m_bAllUsers != allUsers) {
            m_bAllUsers = allUsers;
            emit allUsersChanged();
        }
    }

    void setUsers(const QStringList &users)
    {
        if (m_users != users) {
            m_users = users;
            emit usersChanged();
        }
    }

    void setPorts(const QStringList &ports)
    {
        if (m_ports != ports) {
            m_ports = ports;
            emit portsChanged();
        }
    }

signals:
    void directoryChanged();
    void shareNameChanged();
    void permissionsChanged();
    void visibilityChanged();
    void descriptionChanged();
    void allUsersChanged();
    void usersChanged();
    void portsChanged();
};


class SambaModel : public QAbstractListModel
{
    Q_OBJECT

private:    // Variables
    QList<SambaItem*> m_shares;

public:     // Variables

private:    // Methods
    SambaItem* createShareFromData(const QVariantMap &data)
    {
        SambaItem* share = new SambaItem(this);
        share->setDirectory(data["directory"].toString());
        share->setShareName(data["shareName"].toString());
        share->setPermissions(data["permissions"].toString());
        share->setVisibility(data["visibility"].toString());
        share->setDescription(data["description"].toString());
        share->setbAllUsers(data["bAllUsers"].toBool());

        // bAllUsersがtrueの場合は空の配列を設定、そうでない場合はnewData.usersを設定
        if (data["bAllUsers"].toBool()) {
            share->setUsers(QStringList());
        }
        else {
            share->setUsers(data["users"].toStringList());
        }

        if (data["ports"].toStringList().isEmpty()) {
            share->setPorts(QStringList());
        }
        else {
            share->setPorts(data["ports"].toStringList());
        }

        return share;
    }

public:     // Methods
    enum SambaRoles {
        DirectoryRole = Qt::UserRole + 1,
        ShareNameRole,
        PermissionsRole,
        VisibilityRole,
        DescriptionRole,
        AllUsersRole,
        UsersRole,
        PortsRole
    };

    // Constructor
    explicit SambaModel(QObject *parent = nullptr) : QAbstractListModel(parent)
    {}

    int rowCount(const QModelIndex &parent = QModelIndex()) const override
    {
        if (parent.isValid()) return 0;
        return m_shares.count();
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override
    {
        if (!index.isValid() || index.row() >= m_shares.count())
            return QVariant();

        SambaItem *item = m_shares[index.row()];
        switch (role) {
        case DirectoryRole:
            return item->directory();
        case ShareNameRole:
            return item->shareName();
        case PermissionsRole:
            return item->permissions();
        case VisibilityRole:
            return item->visibility();
        case DescriptionRole:
            return item->description();
        case AllUsersRole:
            return item->bAllUsers();
        case UsersRole:
            return item->users();
        default:
            return QVariant();
        }
    }

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override
    {
        if (!index.isValid() || index.row() >= m_shares.count()) return false;

        SambaItem *item = m_shares[index.row()];
        bool changed = false;

        switch (role) {
            case DirectoryRole:
                if (item->directory() != value.toString()) {
                    item->setDirectory(value.toString());
                    changed = true;
                }
                break;
            case ShareNameRole:
                if (item->shareName() != value.toString()) {
                    item->setShareName(value.toString());
                    changed = true;
                }
                break;
            case PermissionsRole:
                if (item->permissions() != value.toString()) {
                    item->setPermissions(value.toString());
                    changed = true;
                }
                break;
            case VisibilityRole:
                if (item->visibility() != value.toString()) {
                    item->setVisibility(value.toString());
                    changed = true;
                }
                break;
            case DescriptionRole:
                if (item->description() != value.toString()) {
                    item->setDescription(value.toString());
                    changed = true;
                }
                break;
            case AllUsersRole:
                if (item->bAllUsers() != value.toBool()) {
                    item->setbAllUsers(value.toBool());
                    // bAllUsersがtrueの場合、usersリストをクリア
                    if (value.toBool()) {
                        item->setUsers(QStringList());
                    }
                    changed = true;
                }
                break;
            case UsersRole:
                if (item->users() != value.toStringList()) {
                    // bAllUsersがfalseの場合のみusersを更新
                    if (!item->bAllUsers()) {
                        item->setUsers(value.toStringList());
                        changed = true;
                    }
                }
                break;
            case PortsRole:
                if (item->ports() != value.toStringList()) {
                    // portsが空ではない場合のみportsを更新
                    if (!item->ports().isEmpty()) {
                        item->setPorts(value.toStringList());
                        changed = true;
                    }
                }
                break;
        }

        if (changed) {
            emit dataChanged(index, index, QVector<int>() << role);
            return true;
        }

        return false;
    }

    QHash<int, QByteArray> roleNames() const override
    {
        QHash<int, QByteArray> roles;
        roles[DirectoryRole]    = "directory";
        roles[ShareNameRole]    = "shareName";
        roles[PermissionsRole]  = "permissions";
        roles[VisibilityRole]   = "visibility";
        roles[DescriptionRole]  = "description";
        roles[AllUsersRole]     = "bAllUsers";
        roles[UsersRole]        = "users";
        roles[PortsRole]        = "ports";

        return roles;
    }

    void appendShare(SambaItem* share)
    {
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        m_shares.append(share);
        endInsertRows();
    }

    Q_INVOKABLE void clearShares()
    {
        beginResetModel();
        qDeleteAll(m_shares);
        m_shares.clear();
        endResetModel();
    }

    // データ取得用のQ_INVOKABLEメソッドを追加
    Q_INVOKABLE QVariantMap getItemData(int index) const
    {
        if (index < 0 || index >= m_shares.count()) return QVariantMap();

        SambaItem*  item = m_shares[index];
        QVariantMap data;
        data["directory"] = item->directory();
        data["shareName"] = item->shareName();
        data["permissions"] = item->permissions();
        data["visibility"] = item->visibility();
        data["description"] = item->description();
        data["bAllUsers"] = item->bAllUsers();
        data["users"] = item->users();
        data["ports"] = item->ports();

        return data;
    }

    Q_INVOKABLE void updateOrAppendShare(int index, const QVariantMap &newData)
    {
        if (index != -1 && index < m_shares.count()) {
            // 既存のデータを更新
            SambaItem* share = m_shares[index];
            share->setDirectory(newData["directory"].toString());
            share->setShareName(newData["shareName"].toString());
            share->setPermissions(newData["permissions"].toString());
            share->setVisibility(newData["visibility"].toString());
            share->setDescription(newData["description"].toString());
            share->setbAllUsers(newData["bAllUsers"].toBool());

            if (newData["bAllUsers"].toBool()) {
                share->setUsers(QStringList());
            }
            else {
                share->setUsers(newData["users"].toStringList());
            }

            if (newData["ports"].toStringList().isEmpty()) {
                share->setPorts(QStringList());
            }
            else {
                share->setPorts(newData["ports"].toStringList());
            }

            // モデルのデータが変更されたことを通知
            QModelIndex modelIndex = createIndex(index, 0);
            emit dataChanged(modelIndex, modelIndex);
        }
        else {
            // 新しいデータを追加
            SambaItem* newShare = createShareFromData(newData);
            appendShare(newShare);
        }
    }
};


#endif // SAMBAMODEL_H
