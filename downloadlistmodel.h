#ifndef DOWNLOADLISTMODEL_H
#define DOWNLOADLISTMODEL_H

#include <QAbstractListModel>
#include <QJsonObject>
#include <QJsonArray>

class DownloadListModel : public QAbstractListModel
{
    Q_OBJECT
    enum DOWNLOAD_FILE_INFO {
        FILE_NAME = 1,
        FILE_SIZE,
        FILE_ICON,
        FILE_DOWN_SIZE,
        FILE_SIZE_FORMAT,
        DOWNLOAD_SPEED,
        DOWNLOAD_PROGRESS,
        LOCAL_PATH
    };

    Q_PROPERTY(QString downloadNum MEMBER m_downloadNum  NOTIFY downloadNumChanged FINAL)

signals:
    void downloadNumChanged();

public slots:
    void removeDownItem(int index, bool downloadSuccess, bool cancel);
    void updateProgress(double dNow, double dTotal,
                        const QString& speedVal, const QString& sizeFormat);
public:
    explicit DownloadListModel(QObject *parent = nullptr);
    static DownloadListModel* pDownloadListModel;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    void addDownloadItem(const QJsonObject& item);

private:
    QString m_downloadNum;
    QList<QJsonObject> m_downloadList;
};

#endif // DOWNLOADLISTMODEL_H
