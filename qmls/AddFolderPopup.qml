import QtQuick 2.8
import QtQuick.Controls 2.5

//新建文件夹
Popup {
    id:addFolderPopup
    width:500 * dpi
    height:260 * dpi
    modal:true
    closePolicy: Popup.NoAutoClose
    anchors.centerIn: parent

    onOpened: {
        textInput.clear()
    }

    background: Rectangle {
        color: "#FFECD1"
        radius: 10
        Rectangle {
            id:rectClose
            width: 20 * dpi
            height:20 * dpi
            color: "transparent"
            anchors.top: parent.top
            anchors.topMargin: 15 * dpi
            anchors.right: parent.right
            anchors.rightMargin: 15 * dpi
            Image {
                source: "../res/icon_close_min.png"
                fillMode: Image.PreserveAspectFit
                scale: dpi
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    addFolderPopup.close()
                }
            }
        }

        Text {
            text:"新建文件夹"
            font.pixelSize: 20 * dpi
            color: "#663A00"
            anchors.top: parent.top
            anchors.topMargin: 20 * dpi
            anchors.horizontalCenter: parent.horizontalCenter
        }


        Row {
            spacing: 10 * dpi
            anchors.centerIn: parent
            Text {
                text:"文件夹名称"
                font.pixelSize: 16 * dpi
                color: "#663A00"
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id:textInput
                clip: true
                width:300 * dpi
                height:40 * dpi
                font.pixelSize: 16 * dpi
                selectByMouse:true
                selectedTextColor: "white"
                background: Rectangle {
                    color: "white"
                    radius: 5
                }

                placeholderText: qsTr("")
                placeholderTextColor: "#998161"
            }
        }


        Row {
            spacing: 20 * dpi
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15 * dpi
            Button {
                width: 180 * dpi
                height: 50 * dpi
                background: Rectangle {
                    color: "transparent"
                    radius: 5
                    border.width: 1
                    border.color: "#FF991D"
                }

                Text {
                    text:"取消"
                    font.pixelSize: 14 * dpi
                    color: "#FF991D"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        addFolderPopup.close()
                    }
                }
            }

            Button {
                width: 180 * dpi
                height: 50 * dpi
                background: Rectangle {
                    color: "#F38505"
                    radius: 5
                }

                Text {
                    text:"确认"
                    font.pixelSize: 14 * dpi
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(textInput.text === null || textInput.text === '')
                        {
                            return;
                        }

                        addFolderPopup.close()
                        FtpClient.createDir(textInput.text)
                    }
                }
            }
        }
    }
}
