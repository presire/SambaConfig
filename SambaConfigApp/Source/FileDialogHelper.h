#ifndef FILEDIALOGHELPER_H
#define FILEDIALOGHELPER_H

#include <QObject>

class FileDialogHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString selectedFile READ selectedFile WRITE setSelectedFile NOTIFY selectedFileChanged)

private:    // Variables
    QString m_selectedFile;

public:     // Veriables

private:    // Methods
    explicit FileDialogHelper(QObject *parent = nullptr);
    FileDialogHelper(const FileDialogHelper&)            = delete;  // No copies and substitutions allowed due to singleton
    FileDialogHelper& operator=(const FileDialogHelper&) = delete;  // No copies and substitutions allowed due to singleton
    ~FileDialogHelper();

public:     // Methods
    static FileDialogHelper&    getInstance();
    Q_INVOKABLE void            openNativeFileDialog(const QString &title,
                                                     const QString &firstDir,
                                                     const QString &filter);
    QString                     selectedFile() const;

signals:
    void selectedFileChanged();

public slots:
    void setSelectedFile(const QString &fileName);
};

#endif // FILEDIALOGHELPER_H
