#include "selectpathlistmodel.h"


SelectPathListModel* SelectPathListModel::pSelectPathListModel = nullptr;

SelectPathListModel::SelectPathListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    pSelectPathListModel = this;
}


int SelectPathListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_selectPath.size();
}

QVariant SelectPathListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    QJsonObject item = m_selectPath.at(index.row());
    switch (role) {
    case SEL_PATH_NAME:
        return item.value("dirName").toString();
        break;
    case SHOW_ARROW:
        return item.value("showArrow").toBool();
        break;
    default:
        break;
    }
    return QVariant();
}


QHash<int,QByteArray> SelectPathListModel::roleNames() const
{
    QHash<int,QByteArray> rolesHash;
    rolesHash.insert(SEL_PATH_NAME, "dirName");
    rolesHash.insert(SHOW_ARROW, "showArrow");
    return rolesHash;
}

void SelectPathListModel::clearDirs()
{
    m_selectPath.clear();
    beginResetModel();
    endResetModel();
}

void SelectPathListModel::addFolder(const QJsonObject& item)
{
    m_selectPath.push_back(item);
    beginResetModel();
    endResetModel();
}


//删除最后一个节点
void SelectPathListModel::delFolder()
{
    if (m_selectPath.empty())
    {
        return;
    }

    m_selectPath.pop_back();
    beginResetModel();
    endResetModel();
}


//删除当前节点之后的节点
void SelectPathListModel::delFolder(const QString& dirName)
{
    bool bFind = false;
    for (auto iter = m_selectPath.begin(); iter != m_selectPath.end();)
    {
        QString strName = iter->value("dirName").toString();
        if (strName.compare(dirName) == 0)
        {
            bFind = true;
        }

        if(bFind && strName.compare(dirName) != 0)
        {
            iter = m_selectPath.erase(iter);
        } else {
            ++iter;
        }
    }

    //更新界面显示
    beginResetModel();
    endResetModel();
}



















