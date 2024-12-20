#ifndef SAMBAUSERSMODEL_H
#define SAMBAUSERSMODEL_H


#include <QAbstractListModel>
#include <QObject>


class SambaUsersModel : public QAbstractListModel
{
    Q_OBJECT

private:    // Variables
    QStringList m_Users;
    QString     m_PDBEditPath;
    QString     m_ErrMsg;

public:    // Variables

private:    // Methods
    QStringList getUsersAndGroups(const QString &pdbEditPath);
    bool        checkPDBEditPermissions(const QString &pdbEditPath);
    QString     getCurrentUsername();
    QStringList getUserGroups();

public:     // Methods
    explicit                SambaUsersModel(QObject *parent = nullptr);
    Q_INVOKABLE void        refreshUserList(const QString &pdbEditPath);
    Q_INVOKABLE void        isPDBEditAvailable();
    Q_INVOKABLE QString     getErrorMessage();

    int              rowCount(const QModelIndex &parent = QModelIndex())        const override;
    QVariant         data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
    void pdbEditPathFound(const QString &path);
};


#endif // SAMBAUSERSMODEL_H
