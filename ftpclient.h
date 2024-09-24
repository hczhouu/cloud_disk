#ifndef FTPCLIENT_H
#define FTPCLIENT_H

#include <QObject>
#include <QHash>
#include <QTimer>
#include <qurlinfo.h>
#include "curl/curl.h"


class FtpClient : public QObject
{
    Q_OBJECT

    struct FilesType
    {
        QString typeIcon;
        QString typeDesc;
    };

public:
    explicit FtpClient(QObject *parent = nullptr);
    ~FtpClient();


signals:
    void updateFileInfo(const QJsonArray& fileInfo);
    void showMessage(bool isError, const QString& strMsg);
    void signaUploadComplete();
    void signaDownloadComplete();
    void removeItem(int index, bool uploadSuccess, bool cancel);
    void updateProgress(double uNow, double uTotal,
                        const QString& speedVal, const QString& upSize);

    void removeDownItem(int index, bool downloadSuccess, bool cancel);
    void updateDownloadProgress(double dNow, double dTotal,
                        const QString& speedVal, const QString& sizeFormat);

    void updateUserName(const QString& strUser);

public slots:
    void slotUploadComplete();
    void slotUploadTimeout();
    void slotDownloadComplete();
    void slotDownloadTimeout();

public :
    Q_INVOKABLE void getDirList(bool rootDir, bool isBack, bool refresh,
                                const QVariant& dirPath);
    Q_INVOKABLE void backDir();
    Q_INVOKABLE void forwardDir();
    Q_INVOKABLE void refreshDir();
    Q_INVOKABLE void gotoDir(const QVariant& dirPath);
    Q_INVOKABLE void createDir(const QVariant& dirName);
    Q_INVOKABLE void deleteDirFiles(CURL* pCurl, const QString& name,
                                    bool isFolder, std::string* strBuf);
    Q_INVOKABLE void deleteSelectItem();

    Q_INVOKABLE void downloadFile();
    Q_INVOKABLE void uploadFile(const QVariantList& fileList);
    Q_INVOKABLE void openLocalPath(const QVariant& path);

    Q_INVOKABLE void removeUploadItem(int index);
    Q_INVOKABLE void removeDownloadItem(int index);

    void uploadFileToServer();


private:

    QString m_strCurrentPath;
    QString m_strForwardPath;
    QHash<QString, FilesType> m_hashFileTypeIcon;

    QTimer m_timerUpload;
    QTimer m_timerDownload;
    QString m_strUserName;

    void getDir(const QString& dirPath);
    static size_t OnWriteCallBack(char* buffer, size_t size,
                                  size_t nitems, void* outstream);
    static size_t OnDownloadCallBack(char* buffer, size_t size,
                                     size_t nitems, void* outstream);
    static int OnDownloadProgress(void* clientp, double dltotal, double dlnow,
                                  double ultotal, double ulnow);
    static size_t OnUploadCallBack(char* buffer, size_t size,
                                     size_t nitems, void* instream);
    static int OnUploadProgress(void* clientp, double dltotal, double dlnow,
                                  double ultotal, double ulnow);
    void ParseDirInfo(std::string str);
    QString formatSize(qint64 size);
    bool parseDosDir(const QStringList &tokens, QUrlInfo *info);
    void downloadFileImp();
    void refreshUsege();
    void parseDirList(CURL* pCurl, const std::string& strData, const QString& currPath);
    void requestDirInfo(CURL* pCurl, const QString& dirName, const QString& currPath);
    QString encryptoData(const QString& rawData);
    QString decryptoData(const QString& rawData);
};

#endif // FTPCLIENT_H
