QT += quick gui qml widgets

QMAKE_PROJECT_DEPTH = 0

SOURCES += \
        allfileslistmodel.cpp \
        completelistmodel.cpp \
        downloadlistmodel.cpp \
        ftpclient.cpp \
        main.cpp \
        qaesencryption.cpp \
        qftp.cpp \
        qurlinfo.cpp \
        selectpathlistmodel.cpp \
        uploadlistmodel.cpp

RESOURCES += qml.qrc \
    images.qrc

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


win32:CONFIG(release, debug|release):{
    DESTDIR =$$PWD/Bin64/CloudDisk
    UI_DIR = $$PWD/tmp/release/ui
    MOC_DIR = $$PWD/tmp/release/moc
    OBJECTS_DIR = $$PWD/tmp/release/obj
    RCC_DIR = $$PWD/tmp/release/rcc
}
else:win32:CONFIG(debug, debug|release):{
    DESTDIR =$$PWD/Bin64/debug
    UI_DIR = $$PWD/tmp/debug/ui
    MOC_DIR = $$PWD/tmp/debug/moc
    OBJECTS_DIR = $$PWD/tmp/debug/obj
    RCC_DIR = $$PWD/tmp/debug/rcc
}

INCLUDEPATH += $$PWD/third/libcurl/include
LIBS += -L$$PWD/third/libcurl/libs/x64
LIBS += -llibcurl_imp


RC_FILE += main.rc

HEADERS += \
    aesni/aesni-enc-cbc.h \
    aesni/aesni-enc-ecb.h \
    aesni/aesni-key-exp.h \
    aesni/aesni-key-init.h \
    allfileslistmodel.h \
    completelistmodel.h \
    downloadlistmodel.h \
    ftpclient.h \
    qaesencryption.h \
    qftp.h \
    qurlinfo.h \
    selectpathlistmodel.h \
    uploadlistmodel.h
