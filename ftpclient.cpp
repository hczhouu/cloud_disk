#include "ftpclient.h"
#include <QtConcurrent/QtConcurrent>
#include <QJsonDocument>
#include <QJsonArray>
#include <QFileDialog>
#include <QDesktopServices>
#include <QDebug>
#include <atomic>
#include <QGuiApplication>
#include <QJsonObject>
#include "allfileslistmodel.h"
#include "selectpathlistmodel.h"
#include "uploadlistmodel.h"
#include "downloadlistmodel.h"
#include "qaesencryption.h"

static QString BASE_URL = "";
static QString USER_PWD = "";
static std::atomic<int> flagCancelUpload;
static std::atomic<int> flagCancelDownload;
static std::string strBufferData = "";
static QList<QString> uploadFileList;
static QList<QString> downloadFileList;
static QString donwloadPath = "";

static std::atomic<double> uploadTotalSize;
static std::atomic<double> uploadSize;
static std::atomic<double> lastUploadSize;

static std::atomic<double> downloadTotalSize;
static std::atomic<double> downloadSize;
static std::atomic<double> lastDownloadSize;

static qint64 diskUsage = 0;
const QString CRYPTO_KEY = "!@#678TgaE10~%^*";

#define ValueMax_B    pow(1024,1)
#define ValueMax_KB   pow(1024,2)
#define ValueMax_MB   pow(1024,3)
#define ValueMax_G    pow(1024,4)


FtpClient::FtpClient(QObject *parent)
    : QObject{parent}
{
    curl_global_init(CURL_GLOBAL_ALL);
    m_strCurrentPath = "";
    m_strForwardPath = "";
    flagCancelUpload.store(0);
    flagCancelDownload.store(0);

    m_timerUpload.setInterval(1000);
    m_timerDownload.setInterval(1000);


    connect(&m_timerUpload, &QTimer::timeout, this, &FtpClient::slotUploadTimeout);
    connect(&m_timerDownload, &QTimer::timeout, this, &FtpClient::slotDownloadTimeout);
    connect(this, &FtpClient::signaUploadComplete, this, &FtpClient::slotUploadComplete);
    connect(this, &FtpClient::signaDownloadComplete, this, &FtpClient::slotDownloadComplete);


    QSettings setting("HKEY_CURRENT_USER\\SOFTWARE\\SRC",
                      QSettings::NativeFormat);
    QString userName =  decryptoData(setting.value("userName").toString());
    QString userPass =  decryptoData(setting.value("userToken").toString());
    USER_PWD = userName + ":" + userPass;

    m_strUserName = userName.replace(userName.mid(3, 4),"****");
    donwloadPath = setting.value("downLoadPath", "C:\\YouBoxDownload").toString();

    QString strApplicationDir = QGuiApplication::applicationDirPath();
    QDir dirs(strApplicationDir);
    dirs.cdUp();
    QString cfgPath = dirs.path() + "/server-config.ini";
    QSettings settings(cfgPath, QSettings::IniFormat);
    QString srvHost = settings.value("server-config/disk_srv_pub").toString();
    QString srvPort = settings.value("server-config/disk_srv_port").toString();
    BASE_URL = "ftp://" + srvHost +  ":" + srvPort + "/";
    qDebug() << BASE_URL;

    m_hashFileTypeIcon.insert("EXE", FilesType{"../res/icon_exe_big",u8"应用程序"});
    m_hashFileTypeIcon.insert("ZIP", FilesType{"../res/icon_zip_big.png",u8"ZIP压缩文件"});
    m_hashFileTypeIcon.insert("RAR", FilesType{"../res/icon_zip_big.png",u8"RAR压缩文件"});
    m_hashFileTypeIcon.insert("TXT", FilesType{"../res/icon_txt_big.png",u8"文本文件"});
    m_hashFileTypeIcon.insert("XLS", FilesType{"../res/icon_xls_big.png",u8"Excel文档"});
    m_hashFileTypeIcon.insert("XLSX",FilesType{"../res/icon_xls_big.png",u8"Excel文档"});
    m_hashFileTypeIcon.insert("MP3", FilesType{"../res/icon_video_big.png",u8"MP3音频文件"});
    m_hashFileTypeIcon.insert("MP4", FilesType{"../res/icon_video_big.png",u8"MP4视频文件"});
    m_hashFileTypeIcon.insert("AVI", FilesType{"../res/icon_video_big.png",u8"AVI视频文件"});
    m_hashFileTypeIcon.insert("MKV", FilesType{"../res/icon_video_big.png",u8"MKV视频文件"});
    m_hashFileTypeIcon.insert("RMVB",FilesType{"../res/icon_video_big.png",u8"RMVB视频文件"});
    m_hashFileTypeIcon.insert("PPT", FilesType{"../res/icon_ppt_big.png",u8"PPT文档"});
    m_hashFileTypeIcon.insert("DOC", FilesType{"../res/icon_word_big.png",u8"DOC文档"});
    m_hashFileTypeIcon.insert("PDF", FilesType{"../res/icon_pdf_big.png",u8"PDF文件"});
    m_hashFileTypeIcon.insert("PNG", FilesType{"../res/icon_image_big.png",u8"PNG图片文件"});
    m_hashFileTypeIcon.insert("JPG", FilesType{"../res/icon_image_big.png",u8"JPG图片文件"});
    m_hashFileTypeIcon.insert("JPEG", FilesType{"../res/icon_image_big.png",u8"JPEG图片文件"});
    m_hashFileTypeIcon.insert("ISO", FilesType{"../res/icon_iso_big.png",u8"镜像文件"});
    m_hashFileTypeIcon.insert("DLL", FilesType{"../res/icon_dll_big.png",u8"应用程序扩展"});
}


FtpClient::~FtpClient()
{
    curl_global_cleanup();
}


QString FtpClient::formatSize(qint64 size)
{
    QString result = "0";
    double value = 0.00;
    if(size > 0 && size < ValueMax_B)
    {
        result = QString("%1").arg(size)+QString(" B");
    }
    else if((size >= ValueMax_B) && (size < ValueMax_KB))
    {
        value = size/ValueMax_B;
        result = QString::number(value,'f',1)+QString(" KB");
    }
    else if((size >= ValueMax_KB) && (size < ValueMax_MB))
    {
        value = size/ValueMax_KB;
        result = QString::number(value,'f',1)+QString(" MB");
    }
    else if((size >= ValueMax_MB) && (size < ValueMax_G))
    {
        value = size/ValueMax_MB;
        result = QString::number(value,'f',1)+QString(" GB");
    }
    return result;
}


size_t FtpClient::OnWriteCallBack(char* buffer, size_t size,
                                  size_t nitems, void* outstream)
{
    if (nullptr == buffer || nullptr == outstream)
        return size * nitems;

    std::string* pBuf = reinterpret_cast<std::string*>(outstream);
    pBuf->append(buffer, size * nitems);
    return size * nitems;
}


//解析目录信息
void FtpClient::ParseDirInfo(std::string str)
{

    QRegExp dosPattern(QLatin1String("^(\\d\\d-\\d\\d-\\d\\d\\d?\\d?\\ \\ \\d\\d:\\d\\d[AP]M)\\s+"
                                     "(<DIR>|\\d+)\\s+(\\S.*)$"));

    QString bufferStr =  QString::fromLatin1(str.data());
    QStringList strList = bufferStr.split("\r\n");
    QJsonArray jsonArrDir, jsonArrFiles;
    for (int i = 0; i < strList.size(); ++i)
    {
        QUrlInfo info;
        if (dosPattern.indexIn(strList.at(i).trimmed()) != 0)
        {
            continue;
        }

        if(!parseDosDir(dosPattern.capturedTexts(), &info))
        {
            continue;
        }

        QJsonObject jsonItem;
        jsonItem.insert("fileTime", info.lastModified().toLocalTime().toString("yyyy-MM-dd hh:mm:ss"));
        jsonItem.insert("isFolder", info.isDir());
        jsonItem.insert("fileName", QString::fromLocal8Bit(info.name().toLatin1()));
        if (info.isDir())
        {
            jsonItem.insert("fileDesc", u8"文件夹");
            jsonItem.insert("fileIcon", "../res/icon_folder_big.png");
            jsonItem.insert("fileSize", 0);
            jsonItem.insert("fileSizeFormat", "");
            jsonItem.insert("fileTransfer", "");
            jsonArrDir.push_back(jsonItem);
        } else {
            QString fileType = info.name().mid(info.name().lastIndexOf(".") + 1, info.name().size()).toUpper();
            auto iter = m_hashFileTypeIcon.find(fileType);
            if(iter != m_hashFileTypeIcon.end())
            {
                jsonItem.insert("fileDesc", iter.value().typeDesc);
                jsonItem.insert("fileIcon", iter.value().typeIcon);

            } else {
                jsonItem.insert("fileDesc", u8"未知文件");
                jsonItem.insert("fileIcon", "../res/icon_unknow_big.png");
            }

            jsonItem.insert("fileSize", info.size());
            jsonItem.insert("fileSizeFormat", formatSize(info.size()));
            jsonItem.insert("fileTransfer", formatSize(info.size()));
            jsonArrFiles.push_back(jsonItem);
        }
    }

    for (auto iter : jsonArrFiles)
    {
        jsonArrDir.append(iter);
    }

    emit updateFileInfo(jsonArrDir);
}


bool FtpClient::parseDosDir(const QStringList &tokens, QUrlInfo *info)
{
    // DOS style, 3 + 1 entries
    // 01-16-02  11:14AM       <DIR>          epsgroup
    // 06-05-03  03:19PM                 1973 readme.txt
    if (tokens.size() != 4)
        return false;

    QString name = tokens.at(3);
    info->setName(name);
    info->setSymLink(name.toLower().endsWith(QLatin1String(".lnk")));

    if (tokens.at(2) == QLatin1String("<DIR>")) {
        info->setFile(false);
        info->setDir(true);
    } else {
        info->setFile(true);
        info->setDir(false);
        info->setSize(tokens.at(2).toLongLong());
    }

    // Note: We cannot use QFileInfo; permissions are for the server-side
    // machine, and QFileInfo's behavior depends on the local platform.
    int permissions = QUrlInfo::ReadOwner | QUrlInfo::WriteOwner
                      | QUrlInfo::ReadGroup | QUrlInfo::WriteGroup
                      | QUrlInfo::ReadOther | QUrlInfo::WriteOther;
    QString ext;
    int extIndex = name.lastIndexOf(QLatin1Char('.'));
    if (extIndex != -1)
        ext = name.mid(extIndex + 1);
    if (ext == QLatin1String("exe") || ext == QLatin1String("bat") || ext == QLatin1String("com"))
        permissions |= QUrlInfo::ExeOwner | QUrlInfo::ExeGroup | QUrlInfo::ExeOther;
    info->setPermissions(permissions);

    info->setReadable(true);
    info->setWritable(info->isFile());

    QDateTime dateTime;
#ifndef QT_NO_DATESTRING
    dateTime = QLocale::c().toDateTime(tokens.at(1), QLatin1String("MM-dd-yy  hh:mmAP"));
    if (dateTime.date().year() < 1971) {
        dateTime.setDate(QDate(dateTime.date().year() + 100,
                               dateTime.date().month(),
                               dateTime.date().day()));
    }
#endif

    info->setLastModified(dateTime);
    return true;
}


//获取目录列表
void FtpClient::getDirList(bool rootDir, bool isBack, bool refresh, const QVariant& dirPath)
{
    emit updateUserName(m_strUserName);
    if (!refresh)
    {
        //根目录
        if (rootDir)
        {
            if (isBack)
            {
                SelectPathListModel::pSelectPathListModel->delFolder();
            } else {
                QJsonObject item;
                item.insert("dirName", u8"我的文件");
                item.insert("showArrow", true);
                SelectPathListModel::pSelectPathListModel->addFolder(item);
            }

        } else {

            if (m_strCurrentPath.isEmpty())
            {
                m_strCurrentPath.append(dirPath.toString());
            } else {
                m_strCurrentPath.append("/");
                m_strCurrentPath.append(dirPath.toString());
            }

            if (isBack)
            {
                SelectPathListModel::pSelectPathListModel->delFolder();
            } else {
                QJsonObject item;
                item.insert("dirName", dirPath.toString());
                item.insert("showArrow", true);
                SelectPathListModel::pSelectPathListModel->addFolder(item);
            }

        }
    } else {
        if (m_strCurrentPath.isEmpty())
        {
            m_strCurrentPath.append(dirPath.toString());
        } else {
            m_strCurrentPath.append("/");
            m_strCurrentPath.append(dirPath.toString());
        }
    }

    connect(this, &FtpClient::updateFileInfo,
            AllFilesListModel::pAllFileListModel,
            &AllFilesListModel::updateDirList, Qt::UniqueConnection);


    getDir(m_strCurrentPath);

    //refreshUsege();
}

//获取目录信息
void FtpClient::getDir(const QString& dirPath)
{
    std::string strBuffer = "";
    QtConcurrent::run([=](){
        std::string strCmd = "CWD ";
        strCmd.append(dirPath.toLocal8Bit());
        struct curl_slist* headerlist = NULL;
        headerlist = curl_slist_append(headerlist, strCmd.data());
        CURL* pCurl = curl_easy_init();
        curl_easy_setopt(pCurl, CURLOPT_URL, BASE_URL.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_USERPWD, USER_PWD.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_QUOTE, headerlist);
        curl_easy_setopt(pCurl, CURLOPT_WRITEFUNCTION, OnWriteCallBack);
        curl_easy_setopt(pCurl, CURLOPT_WRITEDATA, &strBuffer);
        curl_easy_setopt(pCurl, CURLOPT_CONNECTTIMEOUT, 5L);
        curl_easy_setopt(pCurl, CURLOPT_TIMEOUT, 0);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPALIVE, 1L);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPIDLE, 1000L);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPINTVL, 60L);
        CURLcode curlCode = curl_easy_perform(pCurl);
        curl_slist_free_all(headerlist);
        if (curlCode != CURLE_OK)
        {
            emit showMessage(true, u8"个人云盘连接失败,请联系技术支持");
            qDebug() <<"dirlist error: "<< curl_easy_strerror(curlCode);
        } else {
            ParseDirInfo(strBuffer);
        }

        curl_easy_cleanup(pCurl);
    });
}


//返回上层目录
void FtpClient::backDir()
{
    if (m_strCurrentPath.isEmpty())
    {
        return;
    }

    int pos = m_strCurrentPath.lastIndexOf("/");
    if (pos == -1)
    {
        m_strCurrentPath = "";
        getDirList(true, true, false,  m_strCurrentPath);
    } else {
        QString strBackPath = m_strCurrentPath.mid(0, pos);
        m_strCurrentPath = "";
        getDirList(false, true, false, strBackPath);
    }
}


//前进目录
void FtpClient::forwardDir()
{

}



//跳转到目标目录
void FtpClient::gotoDir(const QVariant& dirPath)
{
    QString dirName = dirPath.toString();
    if (dirName == u8"我的文件")
    {
        m_strCurrentPath = "";
        getDir("");
        SelectPathListModel::pSelectPathListModel->delFolder(dirName);
    } else {

        if (m_strCurrentPath.right(dirName.length()).compare(dirName) != 0)
        {
            QString dstPath = m_strCurrentPath.mid(0,m_strCurrentPath.lastIndexOf(dirName)
                                                          + dirName.length());
            m_strCurrentPath = dstPath;
            getDir(dstPath);
            SelectPathListModel::pSelectPathListModel->delFolder(dirName);
        }
    }
}



//刷新当前目录
void FtpClient::refreshDir()
{
    QString currPath = m_strCurrentPath;
    m_strCurrentPath.clear();
    getDirList(false, false, true, currPath);
}


//新建文件夹
void FtpClient::createDir(const QVariant& dirName)
{
    QString strDirs = m_strCurrentPath;
    if (!m_strCurrentPath.isEmpty())
    {
        strDirs.append("/");
    }

    strDirs.append(dirName.toString());
    QtConcurrent::run([=](){
        std::string strBuffer = "";
        struct curl_slist* headerlist = NULL;
        std::string strCmd = "MKD ";
        strCmd.append(strDirs.toLocal8Bit());
        headerlist = curl_slist_append(headerlist, strCmd.data());
        CURL* pCurl =  curl_easy_init();
        curl_easy_setopt(pCurl, CURLOPT_URL, BASE_URL.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_USERPWD, USER_PWD.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_QUOTE, headerlist);
        curl_easy_setopt(pCurl, CURLOPT_WRITEFUNCTION, OnWriteCallBack);
        curl_easy_setopt(pCurl, CURLOPT_WRITEDATA, &strBuffer);
        curl_easy_setopt(pCurl, CURLOPT_CONNECTTIMEOUT, 5L);
        curl_easy_setopt(pCurl, CURLOPT_TIMEOUT, 0);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPALIVE, 1L);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPIDLE, 1000L);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPINTVL, 60L);
        CURLcode curlCode = curl_easy_perform(pCurl);
        if (curlCode != CURLE_OK)
        {
            qDebug() << curl_easy_strerror(curlCode);
            emit showMessage(true, u8"新建文件夹失败");
        }

        curl_slist_free_all(headerlist);
        curl_easy_cleanup(pCurl);
        getDir(m_strCurrentPath);
    });
}


//删除文件或目录
void FtpClient::deleteDirFiles(CURL* pCurl, const QString& name,
                               bool isFolder, std::string* strBuf)
{
    std::string strCmd;
    if(isFolder)
    {
        strCmd.append("RMD ");
        strCmd.append(name.toLocal8Bit());

    } else {
        strCmd.append("DELE ");
        strCmd.append(name.toLocal8Bit());
    }

    strBuf->clear();
    struct curl_slist* headerlist = NULL;
    headerlist = curl_slist_append(headerlist, strCmd.data());
    curl_easy_setopt(pCurl, CURLOPT_QUOTE, headerlist);
    CURLcode curlCode = curl_easy_perform(pCurl);
    curl_slist_free_all(headerlist);
    if (curlCode != CURLE_OK)
    {
        emit showMessage(true, u8"不支持删除非空文件夹");
        qDebug() << "DELETE FILE : "<< curl_easy_strerror(curlCode) << curlCode;
    }
}


//删除选中文件
void FtpClient::deleteSelectItem()
{
    QHash<int, QJsonObject> selectItems;
    AllFilesListModel::pAllFileListModel->getselectItems(selectItems);
    if (selectItems.empty())
    {
        emit showMessage(true, u8"请选择需要删除的文件");
        return;
    }

    QtConcurrent::run([=](){
        std::string strBuffer = "";
        CURL* pCurl =  curl_easy_init();
        curl_easy_setopt(pCurl, CURLOPT_URL, BASE_URL.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_USERPWD, USER_PWD.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_CONNECTTIMEOUT, 2L);
        curl_easy_setopt(pCurl, CURLOPT_WRITEFUNCTION, OnWriteCallBack);
        curl_easy_setopt(pCurl, CURLOPT_WRITEDATA, &strBuffer);
        curl_easy_setopt(pCurl, CURLOPT_TIMEOUT, 0);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPALIVE, 1L);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPIDLE, 1000L);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPINTVL, 60L);
        CURLcode curlCode = curl_easy_perform(pCurl);
        if (curlCode != CURLE_OK)
        {
            curl_easy_cleanup(pCurl);
            emit showMessage(true, u8"连接个人云盘失败");
            return;
        }

        std::string strCmd;
        for (auto iter = selectItems.begin();
             iter != selectItems.end(); ++iter)
        {
            QJsonObject item = iter.value();
            bool isFolder = item.value("isFolder").toBool();
            QString fileName = item.value("fileName").toString();

            QString pathName = m_strCurrentPath;
            if(!m_strCurrentPath.isEmpty())
            {
                pathName.append("/");
            }

            pathName.append(fileName);
            deleteDirFiles(pCurl, pathName, isFolder, &strBuffer);
        }

        curl_easy_cleanup(pCurl);
        getDir(m_strCurrentPath);
    });
}


//文件下载
void FtpClient::downloadFile()
{
    if (AllFilesListModel::pAllFileListModel == nullptr ||
        DownloadListModel::pDownloadListModel == nullptr)
    {
        return;
    }

    QHash<int, QJsonObject> selectItems;
    AllFilesListModel::pAllFileListModel->getselectItems(selectItems);
    if (selectItems.empty())
    {
        emit showMessage(true, u8"请选择需要下载的文件");
        return;
    }

    for (auto iter : selectItems)
    {
        iter.insert("localPath", donwloadPath);
        if (!iter.value("isFolder").toBool())
        {
            downloadFileList.push_back(iter.value("fileName").toString());
            DownloadListModel::pDownloadListModel->addDownloadItem(iter);
        }
    }

    if (!m_timerDownload.isActive() &&
        !downloadFileList.empty())
    {
        connect(this, &FtpClient::removeDownItem,
                DownloadListModel::pDownloadListModel,
                &DownloadListModel::removeDownItem, Qt::UniqueConnection);
        connect(this, &FtpClient::updateDownloadProgress,
                DownloadListModel::pDownloadListModel,
                &DownloadListModel::updateProgress, Qt::UniqueConnection);

        emit showMessage(false, QString(u8"添加%1个下载任务成功").arg(downloadFileList.size()));
        m_timerDownload.start();
        downloadFileImp();
    }

    return;
}


void FtpClient::downloadFileImp()
{
    lastDownloadSize.store(0);
    flagCancelDownload.store(0);
    QString fileName = downloadFileList.takeFirst();
    QtConcurrent::run([=](){

        QString strPath = QDir::fromNativeSeparators(donwloadPath);
        QDir dir(strPath);
        if(!dir.exists())
        {
            dir.mkpath(strPath);
        }

        QString filePath = strPath + "/" + fileName;
        QFile oFile(filePath);
        oFile.open(QIODevice::ReadWrite);
        if(!oFile.isOpen())
        {
            emit removeDownItem(0, false, true);
            emit signaDownloadComplete();
            return;
        }

        CURL* pCurl = curl_easy_init();
        std::string remoteUrl = BASE_URL.toStdString();
        QByteArray currPath = m_strCurrentPath.toLocal8Bit();
        if (!m_strCurrentPath.isEmpty())
        {
            remoteUrl.append(curl_easy_escape(pCurl, currPath.data(),
                                              currPath.size()));
            remoteUrl.append("/");
        }

        QByteArray fileNameByte = fileName.toLocal8Bit();
        remoteUrl.append(curl_easy_escape(pCurl, fileNameByte.data(),
                                          fileNameByte.size()));

        curl_easy_setopt(pCurl, CURLOPT_URL, remoteUrl.data());
        curl_easy_setopt(pCurl, CURLOPT_USERPWD, USER_PWD.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_WRITEFUNCTION, OnDownloadCallBack);
        curl_easy_setopt(pCurl, CURLOPT_WRITEDATA, &oFile);
        curl_easy_setopt(pCurl, CURLOPT_NOPROGRESS, 0L);
        curl_easy_setopt(pCurl, CURLOPT_PROGRESSFUNCTION, OnDownloadProgress);

        //当请求在 10 秒内每一秒的传输速率都不足 10 字节时，则判定为超时
        curl_easy_setopt(pCurl, CURLOPT_LOW_SPEED_LIMIT, 10);
        curl_easy_setopt(pCurl, CURLOPT_LOW_SPEED_TIME, 10);
        curl_easy_setopt(pCurl, CURLOPT_NOPROXY, "*");
        CURLcode curlCode = curl_easy_perform(pCurl);
        oFile.close();
        curl_easy_cleanup(pCurl);
        if (curlCode == CURLE_OK)
        {
            emit removeDownItem(0, true, false);
        } else if(curlCode == CURLE_ABORTED_BY_CALLBACK) {
            emit removeDownItem(0, false, true);
        } else {
            qDebug() << "download error: " <<
                curl_easy_strerror(curlCode);
            emit removeDownItem(0, false, false);
        }

        emit signaDownloadComplete();
    });
}

//下载刷新界面进度
void FtpClient::slotDownloadTimeout()
{
    QString sizeDown = formatSize(downloadSize.load());
    QString sizeTotal = formatSize(downloadTotalSize.load());
    qint64 speedVal = (qint64)downloadSize.load() - (qint64)lastDownloadSize.load();
    emit updateDownloadProgress(downloadSize.load(),
                        downloadTotalSize.load(), formatSize(speedVal) + "/s",
                        sizeDown + "/" + sizeTotal);
    lastDownloadSize.store(downloadSize.load());
}


//下载文件回调
size_t FtpClient::OnDownloadCallBack(char* buffer, size_t size,
                                     size_t nitems, void* outstream)
{
    QFile* pFile = reinterpret_cast<QFile*>(outstream);
    if (pFile == NULL)
    {
        return 0;
    }

    return pFile->write(buffer, size * nitems);
}


//下载进度
int FtpClient::OnDownloadProgress(void* clientp, double dltotal, double dlnow,
                              double ultotal, double ulnow)
{
    Q_UNUSED(ultotal);
    Q_UNUSED(ulnow);
    Q_UNUSED(clientp);
    downloadSize.store(dlnow);
    downloadTotalSize.store(dltotal);
    return flagCancelDownload.load();
}


void FtpClient::slotDownloadComplete()
{
    if (downloadFileList.empty())
    {
        m_timerDownload.stop();
        return;
    }

    downloadFileImp();
}

//文件上传
void FtpClient::uploadFile(const QVariantList& fileList)
{
    if (UploadListModel::pUploadListModel == nullptr)
    {
        return;
    }

    QJsonArray jsonFileList;
    for(auto iter : fileList)
    {
        QJsonObject jsonItem;
        QString filePath = iter.toString().mid(8);
        QFileInfo info(filePath);
        if (info.isDir() || !info.exists())
        {
            emit showMessage(true, u8"不支持文件夹上传");
            continue;
        }

        QString fileName = filePath.mid(filePath.lastIndexOf("/") + 1, filePath.length());
        QString fileType = filePath.mid(filePath.lastIndexOf(".") + 1, filePath.length()).toUpper();
        QString localPath = filePath.mid(0, filePath.lastIndexOf("/"));
        auto itFind = m_hashFileTypeIcon.find(fileType);
        if (itFind != m_hashFileTypeIcon.end())
        {
            jsonItem.insert("fileIcon" , itFind.value().typeIcon);
        } else {
            jsonItem.insert("fileIcon" , "../res/icon_unknow_big.png");
        }

        jsonItem.insert("fileSize" , info.size());
        jsonItem.insert("fileSizeFormat" , formatSize(info.size()));
        jsonItem.insert("fileTransfer" , formatSize(info.size()));
        jsonItem.insert("fileName" , fileName);
        jsonItem.insert("uploadSpeed" ,"0 B/s");
        jsonItem.insert("progressVal" , 0);
        jsonItem.insert("localPath" , filePath.mid(0, filePath.lastIndexOf("/")));

        UploadListModel::pUploadListModel->addUploadList(jsonItem);
        uploadFileList.push_back(filePath);
    }

    if (uploadFileList.empty())
    {
        return;
    }

    emit showMessage(false, QString(u8"添加%1个上传任务成功").arg(uploadFileList.size()));
    connect(this, &FtpClient::removeItem,
            UploadListModel::pUploadListModel,
            &UploadListModel::removeItem, Qt::UniqueConnection);
    connect(this, &FtpClient::updateProgress,
            UploadListModel::pUploadListModel,
            &UploadListModel::updateProgress, Qt::UniqueConnection);

    if (!m_timerUpload.isActive())
    {
        m_timerUpload.start();
        uploadFileToServer();
    }

    return;
}


void FtpClient::uploadFileToServer()
{
    lastUploadSize.store(0);
    flagCancelUpload.store(0);

    QString filePath = uploadFileList.takeFirst();
    QString fileName = filePath.mid(filePath.lastIndexOf("/") + 1,
                                    filePath.length());

    QtConcurrent::run([=](){
        QFile oFile(filePath);
        oFile.open(QIODevice::ReadOnly);
        if (!oFile.isOpen())
        {
            emit removeItem(0, false, true);
            emit signaUploadComplete();
            return;
        }

        CURL* pCurl = curl_easy_init();
        std::string remoteUrl = BASE_URL.toStdString();
        if (!m_strCurrentPath.isEmpty())
        {
            remoteUrl.append(curl_easy_escape(pCurl,
                                              m_strCurrentPath.toLocal8Bit().data(),
                                              m_strCurrentPath.toLocal8Bit().size()));
            remoteUrl.append("/");
        }

        remoteUrl.append(curl_easy_escape(pCurl,
                                          fileName.toLocal8Bit().data(),
                                          fileName.toLocal8Bit().size()));

        curl_off_t fileSize = static_cast<curl_off_t>(oFile.size());
        curl_easy_setopt(pCurl, CURLOPT_URL,  remoteUrl.data());
        curl_easy_setopt(pCurl, CURLOPT_USERPWD, USER_PWD.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_INFILESIZE_LARGE, fileSize);
        curl_easy_setopt(pCurl, CURLOPT_FTP_CREATE_MISSING_DIRS, (long)CURLFTP_CREATE_DIR_RETRY);
        curl_easy_setopt(pCurl, CURLOPT_READFUNCTION, OnUploadCallBack);
        curl_easy_setopt(pCurl, CURLOPT_READDATA, &oFile);
        curl_easy_setopt(pCurl, CURLOPT_NOPROGRESS, 0L);
        curl_easy_setopt(pCurl, CURLOPT_PROGRESSFUNCTION, OnUploadProgress);
        curl_easy_setopt(pCurl, CURLOPT_UPLOAD, 1L);
        //当请求在 10 秒内每一秒的传输速率都不足 10 字节时，则判定为超时
        curl_easy_setopt(pCurl, CURLOPT_LOW_SPEED_LIMIT, 10);
        curl_easy_setopt(pCurl, CURLOPT_LOW_SPEED_TIME, 10);
        curl_easy_setopt(pCurl, CURLOPT_NOPROXY, "*");
        CURLcode curlCode = curl_easy_perform(pCurl);
        oFile.close();
        curl_easy_cleanup(pCurl);
        if (curlCode == CURLE_OK)
        {
            emit removeItem(0, true, false);
        } else if (curlCode == CURLE_ABORTED_BY_CALLBACK){
            emit removeItem(0, false, true);
        } else {
            qDebug() << "upload error: " <<
                curl_easy_strerror(curlCode);
            emit removeItem(0, false, false);
        }

        emit signaUploadComplete();
    });

}

//上传进度
size_t FtpClient::OnUploadCallBack(char* buffer, size_t size,
                               size_t nitems, void* instream)
{
    QFile* pFile = reinterpret_cast<QFile*>(instream);
    if (pFile == NULL)
    {
        return 0;
    }

    return pFile->read(buffer, size * nitems);
}


//上传回调
int FtpClient::OnUploadProgress(void* clientp, double dltotal, double dlnow,
                            double ultotal, double ulnow)
{
    Q_UNUSED(dltotal);
    Q_UNUSED(dlnow);
    Q_UNUSED(clientp);
    uploadTotalSize.store(ultotal);
    uploadSize.store(ulnow);
    return flagCancelUpload.load();
}


void FtpClient::slotUploadComplete()
{
    if (uploadFileList.empty())
    {
        m_timerUpload.stop();
        getDir(m_strCurrentPath);
        return;
    }

    uploadFileToServer();
}


//上传刷新界面进度
void FtpClient::slotUploadTimeout()
{
    QString sizeDown = formatSize(uploadSize.load());
    QString sizeTotal = formatSize(uploadTotalSize.load());
    qint64 speedVal = (qint64)uploadSize.load() - (qint64)lastUploadSize.load();
    emit updateProgress(uploadSize.load(),
                        uploadTotalSize.load(), formatSize(speedVal) + "/s",
                        sizeDown + "/" + sizeTotal);
    lastUploadSize.store(uploadSize.load());
}

//打开文件所在路径
void FtpClient::openLocalPath(const QVariant& path)
{
    QString strUrl = "file:///";
    strUrl.append(path.toString());
    QDesktopServices::openUrl(QUrl(strUrl));
}


//界面取消上传
void FtpClient::removeUploadItem(int index)
{
    if (index == 0)
    {
        flagCancelUpload.store(1);
    } else {
        uploadFileList.removeAt(index - 1);
        emit removeItem(index, false, true);
    }
}


//界面取消下载
void FtpClient::removeDownloadItem(int index)
{
    if (index == 0)
    {
        flagCancelDownload.store(1);
    } else {
        downloadFileList.removeAt(index - 1);
        emit removeDownItem(index, false, true);
    }
}


void FtpClient::refreshUsege()
{
    QtConcurrent::run([=](){
        CURL* pCurl = curl_easy_init();
        curl_easy_setopt(pCurl, CURLOPT_URL, BASE_URL.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_USERPWD, USER_PWD.toStdString().data());
        curl_easy_setopt(pCurl, CURLOPT_WRITEFUNCTION, OnWriteCallBack);
        curl_easy_setopt(pCurl, CURLOPT_WRITEDATA, &strBufferData);
        curl_easy_setopt(pCurl, CURLOPT_CONNECTTIMEOUT, 5L);
        curl_easy_setopt(pCurl, CURLOPT_TIMEOUT, 0);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPALIVE, 1L);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPIDLE, 1000L);
        curl_easy_setopt(pCurl, CURLOPT_TCP_KEEPINTVL, 60L);
        CURLcode curlCode = curl_easy_perform(pCurl);
        if(curlCode == CURLE_OK)
        {
            requestDirInfo(pCurl, "", "");
        }
        curl_easy_cleanup(pCurl);
    });
}



void FtpClient::requestDirInfo(CURL* pCurl, const QString& dirName, const QString& currPath)
{
    strBufferData.clear();
    std::string strCmd = "CWD ";
    if (!currPath.isEmpty())
    {
        strCmd.append(currPath.toLocal8Bit());
        strCmd.append("/");
    }
    strCmd.append(dirName.toLocal8Bit());
    qDebug() << "currPath: " << currPath;
    qDebug() << "strCmd: " << QString::fromStdString(strCmd);
    struct curl_slist* headerlist = NULL;
    headerlist = curl_slist_append(headerlist, strCmd.data());
    curl_easy_setopt(pCurl, CURLOPT_QUOTE, headerlist);
    CURLcode curlCode = curl_easy_perform(pCurl);
    curl_slist_free_all(headerlist);
    if (curlCode == CURLE_OK)
    {
        parseDirList(pCurl, strBufferData, currPath);
    } else {
        qDebug() <<"dirlist error: "<< curl_easy_strerror(curlCode);
    }
}


void FtpClient::parseDirList(CURL* pCurl, const std::string& strData, const QString& currPath)
{
    QRegExp dosPattern(QLatin1String("^(\\d\\d-\\d\\d-\\d\\d\\d?\\d?\\ \\ \\d\\d:\\d\\d[AP]M)\\s+"
                                     "(<DIR>|\\d+)\\s+(\\S.*)$"));

    QString bufferStr =  QString::fromLatin1(strData.data());
    QStringList strList = bufferStr.split("\r\n");
    for (int i = 0; i < strList.size(); ++i)
    {
        QUrlInfo info;
        if (dosPattern.indexIn(strList.at(i).trimmed()) != 0)
        {
            continue;
        }

        if(!parseDosDir(dosPattern.capturedTexts(), &info))
        {
            continue;
        }

        if (info.isDir())
        {
            if(!currPath.isEmpty() && info.name() != currPath)
            {
                requestDirInfo(pCurl, info.name(), currPath + "/" + info.name());
            } else {
                requestDirInfo(pCurl, info.name(), "");
            }

        } else {
            diskUsage += info.size();
        }
    }
}

QString FtpClient::encryptoData(const QString& rawData)
{
    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB, QAESEncryption::PKCS7);
    QByteArray enBA = encryption.encode(rawData.toUtf8(), u8"!@#678TgaE10~%^*");
    return QString::fromLatin1(enBA.toBase64());
}


QString FtpClient::decryptoData(const QString& rawData)
{
    // QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB, QAESEncryption::PKCS7);
    // QByteArray  enBA = QByteArray::fromBase64(rawData.toUtf8());
    // QByteArray deBA = encryption.decode(enBA, u8"!@#678TgaE10~%^*");
    // return QString::fromLatin1(QAESEncryption::RemovePadding(deBA, QAESEncryption::PKCS7));

    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB, QAESEncryption::PKCS7);
    QByteArray  enBA = QByteArray::fromBase64(rawData.toUtf8());
    QByteArray deBA = encryption.decode(enBA, CRYPTO_KEY.toUtf8());
    return QString::fromLatin1(QAESEncryption::RemovePadding(deBA, QAESEncryption::PKCS7));
}
