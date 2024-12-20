#include <QDir>
#include <QFileInfo>
#include <QUrl>
#include "FileSelectDialog.h"


FileSelectDialog::FileSelectDialog()
{
}


FileSelectDialog::~FileSelectDialog()
{
}


FileSelectDialog& FileSelectDialog::getInstance()
{
    static FileSelectDialog instance;
    return instance;
}


QString FileSelectDialog::getFirstDirectory(const QUrl &fileUrl)
{
    QString filePath = fileUrl.toLocalFile();

    if (filePath.isEmpty()) {
        return "file:///";
    }

    QFileInfo fileInfo(filePath);

    if (fileInfo.isDir()) {
        return "file://" + filePath;
    }

    return fileInfo.exists(fileInfo.dir().path()) ? "file://" + fileInfo.dir().path() : "file:///";
}


bool FileSelectDialog::getPermissions(const QUrl &folderUrl)
{
    QString path = folderUrl.toLocalFile();
    QFileInfo fileInfo(path);

    return fileInfo.isReadable() && fileInfo.isExecutable();
}
