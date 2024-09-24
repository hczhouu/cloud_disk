#include "allfileslistmodel.h"

AllFilesListModel* AllFilesListModel::pAllFileListModel = nullptr;

AllFilesListModel::AllFilesListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    pAllFileListModel = this;
}

int AllFilesListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_fileInfoList.size();
}

QVariant AllFilesListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    QJsonObject item = m_fileInfoList.at(index.row());
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
    case FILE_SIZE_FORMAT:
    {
        return item.value("fileSizeFormat").toString();
    }
    break;
    case FILE_TIME:
    {
        return item.value("fileTime").toString();
    }
    break;
    case FILE_ICON:
    {
        return item.value("fileIcon").toString();
    }
    break;
    case IS_FOLDER:
    {
        return item.value("isFolder").toBool();
    }
    break;
    case FILE_DESC:
    {
        return item.value("fileDesc").toString();
    }
    break;
    default:
        break;
    }

    return QVariant();
}


QHash<int,QByteArray> AllFilesListModel::roleNames() const
{
    QHash<int,QByteArray> rolesHash;
    rolesHash.insert(FILE_NAME, "fileName");
    rolesHash.insert(FILE_SIZE, "fileSize");
    rolesHash.insert(FILE_SIZE_FORMAT, "fileSizeFormat");
    rolesHash.insert(FILE_TIME, "fileTime");
    rolesHash.insert(IS_FOLDER, "isFolder");
    rolesHash.insert(FILE_ICON, "fileIcon");
    rolesHash.insert(FILE_DESC, "fileDesc");
    return rolesHash;
}


void AllFilesListModel::updateDirList(const QJsonArray& fileInfo)
{
    m_fileInfoList.clear();
    m_selectItemList.clear();
    for(int i = 0; i < fileInfo.size(); ++i)
    {
        QJsonObject item = fileInfo.at(i).toObject();
        m_fileInfoList.push_back(item);
    }

    beginResetModel();
    endResetModel();
}


//添加或删除选中项
void AllFilesListModel::addSelectItem(int index, bool checked)
{
    if (checked)
    {
        m_selectItemList.insert(index, m_fileInfoList.at(index));
    } else {
        auto itFind = m_selectItemList.find(index);
        if (itFind != m_selectItemList.end())
        {
            m_selectItemList.erase(itFind);
        }
    }
}

//全选
void AllFilesListModel::addSelectAllItem(bool checked)
{
    if(checked)
    {
        for (int i = 0; i < m_fileInfoList.size(); ++i)
        {
            m_selectItemList.insert(i, m_fileInfoList.at(i));
        }
    } else {
        m_selectItemList.clear();
    }
}


void AllFilesListModel::getselectItems(QHash<int, QJsonObject>& selectItem)
{
    selectItem.swap(m_selectItemList);
}

