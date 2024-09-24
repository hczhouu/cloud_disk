#include "completelistmodel.h"

CompleteListModel* CompleteListModel::pCompleteListModel = nullptr;

CompleteListModel::CompleteListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    pCompleteListModel = this;
    m_completeCount = "0";

}


int CompleteListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_completeList.size();
}


QVariant CompleteListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    QJsonObject item = m_completeList.at(index.row());
    switch (role) {
    case FILE_NAME:
    {
        return item.value("fileName").toString();
    }
        break;
    case FILE_SIZE:
    {
        return item.value("fileSizeFormat").toString();
    }
    break;
    case FILE_ICON:
    {
        return item.value("fileIcon").toString();
    }
    break;
    case FILE_STATUS:
    {
        return item.value("fileStatus").toString();
    }
    break;
    case FILE_PATH:
    {
        return item.value("localPath").toString();
    }
    break;
    default:
        break;
    }
    return QVariant();
}


QHash<int, QByteArray> CompleteListModel::roleNames() const
{
    QHash<int, QByteArray> rolesHash;
    rolesHash.insert(FILE_NAME, "fileName");
    rolesHash.insert(FILE_SIZE, "fileSize");
    rolesHash.insert(FILE_ICON, "fileIcon");
    rolesHash.insert(FILE_STATUS, "fileStatus");
    rolesHash.insert(FILE_PATH, "localPath");
    return rolesHash;
}


void CompleteListModel::addCompleteItem(const QJsonObject& item)
{
    m_completeList.push_back(item);
    beginResetModel();
    endResetModel();

    m_completeNum = QString("(%1)").arg(m_completeList.size());
    emit completeNumChanged();

    m_completeCount = QString::number(m_completeList.size());
    emit completeCountChanged();
}


void CompleteListModel::removeCompleteItem(int index)
{
    if (m_completeList.size() <= index)
    {
        return;
    }

    m_completeList.removeAt(index);
    beginResetModel();
    endResetModel();

    if (m_completeList.empty())
    {
        m_completeNum = "";
    } else {
        m_completeNum = QString("(%1)").arg(m_completeList.size());
    }

    emit completeNumChanged();

    m_completeCount = QString::number(m_completeList.size());
    emit completeCountChanged();
}
