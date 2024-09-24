#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFont>
#include <QIcon>
#include <QQmlContext>
#include "ftpclient.h"
#include "allfileslistmodel.h"
#include "selectpathlistmodel.h"
#include "uploadlistmodel.h"
#include "downloadlistmodel.h"
#include "completelistmodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("KukaCloudDisk");
    QCoreApplication::setApplicationName("Config");
    //设置全局字体
    QFont font;
    font.setFamily(u8"微软雅黑");
    app.setFont(font);
    app.setWindowIcon(QIcon(":res/main.ico"));

    QQmlApplicationEngine engine;

    qmlRegisterSingletonType<AllFilesListModel>("AllFilesListModel", 1, 0,
                                                      "AllFilesListModel",
                                                      [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                          return new AllFilesListModel();
                                                      });


    qmlRegisterSingletonType<UploadListModel>("UploadListModel", 1, 0,
                                                  "UploadListModel",
                                                  [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                          return new UploadListModel();
                                                  });

    qmlRegisterSingletonType<DownloadListModel>("DownloadListModel", 1, 0,
                                              "DownloadListModel",
                                              [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                  return new DownloadListModel();
                                              });

    qmlRegisterSingletonType<CompleteListModel>("CompleteListModel", 1, 0,
                                                "CompleteListModel",
                                                [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                    return new CompleteListModel();
                                                });


    qmlRegisterSingletonType<SelectPathListModel>("SelectPathListModel", 1, 0,
                                                "SelectPathListModel",
                                                [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                    return new SelectPathListModel();
                                                });


    std::shared_ptr<FtpClient> pClient = std::make_shared<FtpClient>();
    engine.rootContext()->setContextProperty("FtpClient", pClient.get());

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);


    //获取根目录列表
    pClient->getDirList(true, false,false, "");

    return app.exec();
}
