#ifndef ALLFILESLISTMODEL_H
#define ALLFILESLISTMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>

class AllFilesListModel : public QAbstractListModel
{
    Q_OBJECT

    enum FILE_INFO {
        FILE_NAME = 1,
        FILE_SIZE,
        FILE_SIZE_FORMAT,
        FILE_TIME,
        FILE_ICON,
        FILE_DESC,
        IS_FOLDER
    };

public slots:
    void updateDirList(const QJsonArray& fileInfo);

public:
    explicit AllFilesListModel(QObject *parent = nullptr);
    static AllFilesListModel* pAllFileListModel;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    //void updateDirList(const QJsonArray& fileInfo);

    Q_INVOKABLE void addSelectItem(int index, bool checked);
    Q_INVOKABLE void addSelectAllItem(bool checked);

    void getselectItems(QHash<int, QJsonObject>& selectItem);
    void setUserName(const QString& strName);

private:
    QList<QJsonObject> m_fileInfoList;
    QHash<int, QJsonObject> m_selectItemList;
};

#endif // ALLFILESLISTMODEL_H
