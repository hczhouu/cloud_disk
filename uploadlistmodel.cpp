#include "uploadlistmodel.h"
#include "completelistmodel.h"

UploadListModel* UploadListModel::pUploadListModel = nullptr;

UploadListModel::UploadListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    pUploadListModel = this;
}

int UploadListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_uploadFileList.size();
}

QVariant UploadListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    QJsonObject item = m_uploadFileList.at(index.row());
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
    case FILE_UP_SIZE:
    {
        return item.value("fileTransfer").toString();
    }
    break;
    case UPLOAD_SPEED:
    {
        return item.value("uploadSpeed").toString();
    }
    break;
    case UPLOAD_PROGRESS:
    {
        return item.value("progressVal").toInt();
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


QHash<int,QByteArray> UploadListModel::roleNames() const
{
    QHash<int,QByteArray> rolesHash;
    rolesHash.insert(FILE_NAME, "fileName");
    rolesHash.insert(FILE_SIZE, "fileSize");
    rolesHash.insert(FILE_ICON, "fileIcon");
    rolesHash.insert(FILE_UP_SIZE, "fileUpSize");
    rolesHash.insert(FILE_SIZE_FORMAT, "fileSizeFormat");
    rolesHash.insert(UPLOAD_SPEED, "uploadSpeed");
    rolesHash.insert(UPLOAD_PROGRESS, "progressVal");
    rolesHash.insert(LOCAL_PATH, "localPath");
    return rolesHash;
}


void UploadListModel::addUploadList(const QJsonObject& fileItem)
{
    m_uploadFileList.push_back(fileItem);
    beginResetModel();
    endResetModel();

    m_uploadNum = QString("(%1)").arg(m_uploadFileList.size());
    emit uploadNumChanged();
}


void UploadListModel::updateProgress(double uNow, double uTotal,
                                     const QString& speedVal, const QString& upSize)
{
    if (m_uploadFileList.empty())
    {
        return;
    }

    m_uploadFileList[0].insert("fileSize", uTotal);
    m_uploadFileList[0].insert("progressVal", uNow);
    m_uploadFileList[0].insert("uploadSpeed", speedVal);
    m_uploadFileList[0].insert("fileTransfer", upSize);
    beginResetModel();
    endResetModel();
}


void UploadListModel::removeItem(int index, bool uploadSuccess, bool cancel)
{
    if (m_uploadFileList.size() <= index)
    {
        return;
    }

    QJsonObject item = m_uploadFileList.takeAt(index);
    uploadSuccess ? item.insert("fileStatus", u8"上传完成") :
        item.insert("fileStatus", u8"上传失败");
    //添加到完成列表
    if (!cancel && CompleteListModel::pCompleteListModel != nullptr)
    {
        CompleteListModel::pCompleteListModel->addCompleteItem(item);
    }

    beginResetModel();
    endResetModel();

    if (m_uploadFileList.empty())
    {
        m_uploadNum = "";
    } else {
        m_uploadNum = QString("(%1)").arg(m_uploadFileList.size());
    }

    emit uploadNumChanged();
}

