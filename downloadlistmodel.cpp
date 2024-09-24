#include "downloadlistmodel.h"
#include "completelistmodel.h"

DownloadListModel* DownloadListModel::pDownloadListModel = nullptr;

DownloadListModel::DownloadListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    pDownloadListModel = this;
}

int DownloadListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_downloadList.size();
}

QVariant DownloadListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    QJsonObject item = m_downloadList.at(index.row());
    switch (role) {
    case FILE_NAME:
    {
        return item.value("fileName").toString();
    }
        break;
    case FILE_SIZE:
    {
        return item.value("fileSize").toInt();
    }
    break;
    case FILE_ICON:
    {
        return item.value("fileIcon").toString();
    }
    break;
    case FILE_SIZE_FORMAT:
    {
        return item.value("fileSizeFormat").toString();
    }
    break;
    case FILE_DOWN_SIZE:
    {
        return item.value("fileTransfer").toString();
    }
    break;
    case DOWNLOAD_SPEED:
    {
        return item.value("downloadSpeed").toString();
    }
    break;
    case DOWNLOAD_PROGRESS:
    {
        return item.value("downloadProgress").toInt();
    }
    break;
    case LOCAL_PATH:
    {
        return item.value("localPath").toString();
    }
    break;
    default:
        break;
    }
    return QVariant();
}


QHash<int, QByteArray> DownloadListModel::roleNames() const
{
    QHash<int, QByteArray> rolesHash;
    rolesHash.insert(FILE_NAME , "fileName");
    rolesHash.insert(FILE_SIZE , "fileSize");
    rolesHash.insert(FILE_ICON , "fileIcon");
    rolesHash.insert(FILE_DOWN_SIZE , "fileDownSize");
    rolesHash.insert(FILE_SIZE_FORMAT , "fileSizeFormat");
    rolesHash.insert(DOWNLOAD_SPEED , "downloadSpeed");
    rolesHash.insert(DOWNLOAD_PROGRESS , "downloadProgress");
    rolesHash.insert(LOCAL_PATH , "localPath");
    return rolesHash;
}


void DownloadListModel::addDownloadItem(const QJsonObject& item)
{
    m_downloadList.push_back(item);
    beginResetModel();
    endResetModel();

    m_downloadNum = QString("(%1)").arg(m_downloadList.size());
    emit downloadNumChanged();
}


void DownloadListModel::updateProgress(double dNow, double dTotal,
                    const QString& speedVal, const QString& sizeFormat)
{
    if (m_downloadList.empty())
    {
        return;
    }

    m_downloadList[0].insert("fileSize", dTotal);
    m_downloadList[0].insert("downloadProgress", dNow);
    m_downloadList[0].insert("downloadSpeed", speedVal);
    m_downloadList[0].insert("fileTransfer", sizeFormat);
    beginResetModel();
    endResetModel();
}

void DownloadListModel::removeDownItem(int index, bool downloadSuccess, bool cancel)
{
    if (m_downloadList.size() <= index)
    {
        return;
    }

    QJsonObject item = m_downloadList.takeAt(index);
    downloadSuccess ? item.insert("fileStatus", u8"下载完成") :
        item.insert("fileStatus", u8"下载失败");
    //下载完成或失败
    if (!cancel && CompleteListModel::pCompleteListModel != nullptr)
    {
        CompleteListModel::pCompleteListModel->addCompleteItem(item);
    }

    beginResetModel();
    endResetModel();

    if (m_downloadList.empty())
    {
        m_downloadNum = "";
    } else {
        m_downloadNum = QString("(%1)").arg(m_downloadList.size());
    }

    emit downloadNumChanged();
}
