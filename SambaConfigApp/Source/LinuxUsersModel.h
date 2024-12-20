#ifndef LINUXUSERSMODEL_H
#define LINUXUSERSMODEL_H


#include <QAbstractListModel>
#include <QStringList>
#include <QProcess>
#include <pwd.h>


class LinuxUsersModel : public QAbstractListModel
{
    Q_OBJECT

private:    // Variables
    QStringList m_Users;

public:     // Variables

private:    // Methods
    // Get all users name on Linux.
    QStringList getSystemUsers()
    {
        QStringList users;

        struct passwd *pw;

        setpwent();
        while ((pw = getpwent()) != nullptr) {
            users.push_back(pw->pw_name);
        }
        endpwent();

        return users;
    }

public:     // Methods
    explicit LinuxUsersModel(QObject *parent = nullptr) : QAbstractListModel(parent)
    {
        refreshUserList();
    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override
    {
        return m_Users.count();
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override
    {
        if (!index.isValid()) {
            return QVariant();
        }

        if (role == Qt::DisplayRole) {
            return m_Users.at(index.row());
        }

        return QVariant();
    }

    Q_INVOKABLE void refreshUserList()
    {
        beginResetModel();
        m_Users.clear();

        m_Users = getSystemUsers();

        endResetModel();
    }
};


#endif // LINUXUSERSMODEL_H
