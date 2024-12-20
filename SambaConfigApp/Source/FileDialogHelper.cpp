#include <QGuiApplication>
#include <QFileDialog>
#include <QUrl>
#include "FileDialogHelper.h"


FileDialogHelper::FileDialogHelper(QObject *parent) : QObject{parent}
{
}


FileDialogHelper::~FileDialogHelper()
{
}


FileDialogHelper& FileDialogHelper::getInstance()
{
    static FileDialogHelper instance;
    return instance;
}


void FileDialogHelper::openNativeFileDialog(const QString &title, const QString &firstDir, const QString &filter)
{
    // Search for the base directory.
    auto lastSlashIndex = firstDir.lastIndexOf('/');

    QString dir = "";
    if (lastSlashIndex != -1) {
        dir = firstDir.left(lastSlashIndex);

        QDir directory(dir);
        if (directory.exists()) dir = directory.absolutePath();
        else                    dir = QDir::homePath();
    }
    else {
        dir = QDir::homePath();
    }

    QFileDialog fileDlg;
    fileDlg.setFileMode(QFileDialog::ExistingFile);

    // Open file dialog (native).
    auto fileName = fileDlg.getOpenFileName(nullptr, title, dir, filter, nullptr, QFileDialog::DontUseCustomDirectoryIcons);

    if (!fileName.isEmpty()) {
        setSelectedFile(fileName);
    }
}


QString FileDialogHelper::selectedFile() const
{
    return m_selectedFile;
}


void FileDialogHelper::setSelectedFile(const QString &fileName)
{
    if (m_selectedFile != fileName) {
        m_selectedFile = fileName;
        emit selectedFileChanged();
    }
}
