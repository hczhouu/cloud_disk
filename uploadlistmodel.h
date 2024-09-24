#ifndef UPLOADLISTMODEL_H
#define UPLOADLISTMODEL_H

#include <QAbstractListModel>
#include <QJsonObject>
#include <QJsonArray>
#include <QMutex>

class UploadListModel : public QAbstractListModel
{
    Q_OBJECT
    enum UPLOAD_FILE_INFO {
        FILE_NAME = 1,
        FILE_SIZE,
        FILE_ICON,
        FILE_SIZE_FORMAT,
        FILE_UP_SIZE,
        UPLOAD_SPEED,
        UPLOAD_PROGRESS,
        LOCAL_PATH
    };

     Q_PROPERTY(QString uploadNum MEMBER m_uploadNum  NOTIFY uploadNumChanged FINAL)

signals:
    void uploadNumChanged();

public slots :
    void removeItem(int index, bool uploadSuccess, bool cancel);
    void updateProgress(double uNow, double uTotal,
                        const QString& speedVal, const QString& upSize);

public:
    explicit UploadListModel(QObject *parent = nullptr);
    static UploadListModel* pUploadListModel;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int,QByteArray> roleNames() const override;


public:
    Q_INVOKABLE void addUploadList(const QJsonObject& fileItem);

private:
    QMutex m_oMutex;
    QString m_uploadNum;
    QList<QJsonObject> m_uploadFileList;
};

#endif // UPLOADLISTMODEL_H
