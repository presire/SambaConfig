#include <QFileInfo>
#include <QProcess>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <grp.h>
#include <errno.h>
#include "PDBEdit.h"

#ifdef _DEBUG
    #include <QDebug>
#endif


PDBEdit::PDBEdit()
{
}


PDBEdit::~PDBEdit()
{
}


PDBEdit& PDBEdit::getInstance()
{
    static PDBEdit instance;
    return instance;
}


QStringList PDBEdit::getSambaUser(const QString &pdbEditPath)
{
    QStringList users;

    if (!checkPDBEditPermissions(pdbEditPath)) {
    }

    QProcess process;
    process.start(pdbEditPath, QStringList() << "-L");

    if (!process.waitForFinished()) {
        m_ErrMsg = tr("Error: Process failed to start or timed out");
        return users;
    }

    QByteArray output = process.readAllStandardOutput();
    QString outputStr(output);
    QStringList lines = outputStr.split('\n', Qt::SkipEmptyParts);

    for (const QString &line : lines) {
        QStringList parts = line.split(':');
        if (!parts.isEmpty()) {
            users.append(parts.first());
        }
    }

    return users;
}


void PDBEdit::isPDBEditAvailable()
{
    QProcess process;
    process.start("which", QStringList() << "pdbedit");

    if (process.waitForFinished() && process.exitCode() == 0) {
        // pdbedit is found in PATH
        m_PDBEditPath = QString::fromUtf8(process.readAllStandardOutput()).trimmed();
        emit pdbEditPathFound(m_PDBEditPath);

        return;
    }
    else {
        // pdbedit not found in PATH
        return;
    }
}


bool PDBEdit::checkPDBEditPermissions(const QString &pdbEditPath)
{
    QFileInfo fileInfo(pdbEditPath);

    // Check if the pdbedit file exists.
    if (!fileInfo.exists()) {
        m_ErrMsg = tr("pdbedit file not found.");
        return false;
    }

    // Obtain the user name under which the application is running.
    /// When executed as an external command
    /// (Currently unused)
    // QProcess process;
    // process.start("whoami");
    // process.waitForFinished();
    // QString currentUser = QString(process.readAllStandardOutput()).trimmed();

    /// To run using standard libraries and POSIX API
    QString currentUser = getCurrentUsername();
    if (currentUser.isEmpty()) {
        m_ErrMsg = tr("Failed to obtain the user name running this software.");
        return false;
    }

    // Get file owner
    QString fileOwner = fileInfo.owner();

    if (currentUser == fileOwner) {
        // If the owners are the same

        // Check the owner's execution authority
        if (fileInfo.permission(QFile::ExeOwner)) {
            // If the file has execute permission
            return true;
        }
    }

    // In case of different owners, check "group" Execution Authority
    /// To run using standard libraries and POSIX API
    auto currentGroup = getUserGroups();
    if (currentGroup.isEmpty()) {
        m_ErrMsg = tr("Failed to obtain the user groups running this software.");
        return false;
    }

    /// Get File Group
    QString fileGroup = fileInfo.group();
    if (currentGroup.contains(fileGroup)) {
        // Check "others" Execution Authority
        if (fileInfo.permission(QFile::ExeGroup)) {
            // If the groups have execute permission
            return true;
        }
    }

    // In case of different groups, check "others" Execution Authority
    if (fileInfo.permission(QFile::ExeOther)) {
        // If the "other" user has execute permission
        return true;
    }

    // If the all users and all groups do not have execute permission
    return false;
}


QString PDBEdit::getCurrentUsername()
{
    uid_t uid = geteuid();
    struct passwd *pw = getpwuid(uid);

    if (pw) {
        return QString::fromLocal8Bit(pw->pw_name);  // For local encoding of the system
    }

    return QString();
}


QStringList PDBEdit::getUserGroups()
{
    QStringList groups;

    uid_t uid = getuid();
    struct passwd *pw = getpwuid(uid);

    if (!pw) {
        m_ErrMsg = tr("Failed to get user info: %1.").arg(strerror(errno));
        return groups;
    }

    int ngroups = 0;
    if (getgrouplist(pw->pw_name, pw->pw_gid, nullptr, &ngroups) == -1) {
        m_ErrMsg = tr("Failed to get group list size.");
        return groups;
    }

    if (ngroups > 0) {
        QVector<gid_t> gids(ngroups);
        if (getgrouplist(pw->pw_name, pw->pw_gid, gids.data(), &ngroups) == -1) {
            m_ErrMsg = tr("Failed to get group list.");
            return groups;
        }

        for (int i = 0; i < ngroups; i++) {
            errno = 0;
            struct group *gr = getgrgid(gids[i]);
            if (gr) {
                groups.append(QString::fromLocal8Bit(gr->gr_name));
            }
            else {
                if (!m_ErrMsg.isEmpty() && i < (ngroups - 1)) m_ErrMsg += QChar::LineFeed;  // Substitute a newline character after two.
                m_ErrMsg += tr("Failed to get group name for gid%1: %2.").arg(gids[i]).arg(QString::fromLocal8Bit(strerror(errno)));
            }
        }
    }
    else {
        m_ErrMsg = tr("User is not a member of any groups.");
    }

    return groups;
}


QString PDBEdit::getErrorMessage()
{
    return m_ErrMsg;
}
