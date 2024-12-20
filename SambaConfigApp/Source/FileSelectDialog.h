#ifndef FILESELECTDIALOG_H
#define FILESELECTDIALOG_H


#include <QObject>


class FileSelectDialog : public QObject
{
    Q_OBJECT

private:    // Methods
    FileSelectDialog();
    FileSelectDialog(const FileSelectDialog&)            = delete;
    FileSelectDialog& operator=(const FileSelectDialog&) = delete;
    ~FileSelectDialog();

public:     // Methods
    static      FileSelectDialog&   getInstance();
    Q_INVOKABLE QString             getFirstDirectory(const QUrl &fileUrl);
    Q_INVOKABLE bool                getPermissions(const QUrl &folderUrl);
};


#endif // FILESELECTDIALOG_H
