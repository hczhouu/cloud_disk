#ifndef COMPLETELISTMODEL_H
#define COMPLETELISTMODEL_H

#include <QAbstractListModel>
#include <QJsonObject>

class CompleteListModel : public QAbstractListModel
{
    Q_OBJECT

    enum COMPLETE_FILE_INFO {
        FILE_NAME = 1,
        FILE_SIZE,
        FILE_ICON,
        FILE_STATUS,
        FILE_PATH
    };

    Q_PROPERTY(QString completeNum MEMBER m_completeNum NOTIFY completeNumChanged FINAL)
    Q_PROPERTY(QString completeCount MEMBER m_completeCount NOTIFY completeCountChanged FINAL)

signals:
    void completeNumChanged();
    void completeCountChanged();

public:
    explicit CompleteListModel(QObject *parent = nullptr);
    static CompleteListModel* pCompleteListModel;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    void addCompleteItem(const QJsonObject& item);
    Q_INVOKABLE void removeCompleteItem(int index);

private:
    QString m_completeNum;
    QString m_completeCount;
    QList<QJsonObject> m_completeList;
};

#endif // COMPLETELISTMODEL_H
