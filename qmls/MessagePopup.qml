import QtQuick 2.5
import QtQuick.Controls 2.5

Item {
    property bool isError: false
    property string strMsg: ""
    width:parent.width
    height:50 * dpi
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 30* dpi
    anchors.horizontalCenter: parent.horizontalCenter

    Connections {
        target: FtpClient
        function onShowMessage(bError, msgData)
        {
            isError = bError
            strMsg = msgData
            if(msgPopup.opened)
            {
                msgPopup.close()
            }

            msgPopup.open()
        }
    }

    Popup {
        id:msgPopup
        width:rectIcon.width + textContent.contentWidth + 40 * dpi
        height:50 * dpi
        modal:false
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: parent
        background:Rectangle {
            anchors.fill: parent
            color: "#E9EFFC"
            radius: 5
            Row {
                spacing: 10* dpi
                anchors.centerIn: parent
                Rectangle {
                    id:rectIcon
                    width: 32 * dpi
                    height: 32 * dpi
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        source: isError ? "../res/error.png" :
                                           "../res/info.png"
                        anchors.fill: parent
                    }
                }

                Text {
                    id:textContent
                    text:strMsg
                    font.pixelSize: 16 * dpi
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Timer {
            id:timerClose
            repeat: true
            running:false
            interval: 3000
            onTriggered: {
                timerClose.stop()
                msgPopup.close()
            }
        }

        onOpened: {
            timerClose.start()
        }

        onClosed:  {
            timerClose.stop()
        }
    }

}
