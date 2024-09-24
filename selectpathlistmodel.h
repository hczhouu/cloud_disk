#ifndef SELECTPATHLISTMODEL_H
#define SELECTPATHLISTMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>

class SelectPathListModel : public QAbstractListModel
{
    Q_OBJECT
    enum SELECT_PATH_INFO
    {
        SEL_PATH_NAME = 1,
        SHOW_ARROW
    };

public:
    explicit SelectPathListModel(QObject *parent = nullptr);
    static SelectPathListModel* pSelectPathListModel;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int,QByteArray> roleNames() const override;

    void clearDirs();
    void addFolder(const QJsonObject& item);
    void delFolder();
    void delFolder(const QString& dirName);

private:
    QList<QJsonObject> m_selectPath;
};

#endif // SELECTPATHLISTMODEL_H
