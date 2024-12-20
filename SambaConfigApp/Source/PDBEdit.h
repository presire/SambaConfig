#ifndef PDBEDIT_H
#define PDBEDIT_H


#include <QObject>


class PDBEdit : public QObject
{
    Q_OBJECT

private:    // Variables
    QString m_PDBEditPath;
    QString m_ErrMsg;

public:    // Variables

private:    // Methods
    PDBEdit();
    ~PDBEdit();
    PDBEdit(const PDBEdit&) = delete;
    PDBEdit& operator=(const PDBEdit&) = delete;

    bool        checkPDBEditPermissions(const QString &pdbEditPath);
    QString     getCurrentUsername();
    QStringList getUserGroups();

public:     // Methods
    static PDBEdit&         getInstance();
    Q_INVOKABLE void        isPDBEditAvailable();
    Q_INVOKABLE QStringList getSambaUser(const QString &pdbEditPath);
    Q_INVOKABLE QString     getErrorMessage();

signals:
    void pdbEditPathFound(const QString &path);

};


#endif // PDBEDIT_H
