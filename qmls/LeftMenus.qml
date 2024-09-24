import QtQuick 2.15
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.15
import UploadListModel 1.0
import DownloadListModel 1.0
import CompleteListModel 1.0

Item {
    anchors.fill: parent
    property string userNameText: ""
    Connections {
        target: FtpClient
        function onUpdateUserName(userName)
        {
            userNameText = userName
        }
    }

    Column {
        id:columHeadLogo
        anchors.top: parent.top
        anchors.topMargin: 20 * dpi
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10 * dpi
        //头像
        Rectangle {
            width: parent.parent.width
            height:90 * dpi
            color: "transparent"

            Rectangle {
                id:rectHead
                width:90 * dpi
                height:90 * dpi
                color: "transparent"
                border.color: "#82999F"
                radius: 100
                anchors.centerIn: parent
                MouseArea {
                    id: imageRect
                    width: 90 * dpi
                    height: 90 * dpi
                    anchors.centerIn: parent
                    //头像
                    Image {
                        id: nameIamge
                        anchors.fill: parent
                        scale: dpi
                        source: "../res/no-head-logo.png"
                        //source: HttpClient.headLogoUrl
                        visible: false
                        cache: false
                        asynchronous: true
                    }

                    Rectangle{
                        id: mask
                        anchors.fill: parent
                        radius: 100
                        visible: false
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: nameIamge
                        maskSource: mask
                    }
                }
            }
        }

        //用户昵称
        Rectangle {
            width: parent.parent.width
            height:columnUserName.height
            color: "transparent"
            Column {
                id:columnUserName
                spacing: 5 * dpi
                anchors.centerIn: parent
                Text {
                    id:textPhone
                    text:userNameText
                    font.pixelSize: 16 * dpi
                    color: "#818D9D"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

        }
    }


    Column {
        width: parent.width
        anchors.top: columHeadLogo.bottom
        anchors.topMargin: 40 * dpi
        RadioButton {
            id:btnAllFiles
            width: parent.parent.width
            height: 50 * dpi
            checked: true
            background: Rectangle {
                color: btnAllFiles.checked ? "#3D414B" : "transparent"
                Row {
                    id:rowAllFiles
                    anchors.centerIn: parent
                    spacing: 10 * dpi

                    Image {
                        source: btnAllFiles.checked ? "../res/icon_folder_sel.png" :
                                                      "../res/icon_folder.png"
                        fillMode: Image.PreserveAspectFit
                        scale: dpi
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "全部文件"
                        font.pixelSize: 16 * dpi
                        color: btnAllFiles.checked ? "white" : "#818D9D"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

            }

            indicator: Rectangle {
                color: "transparent"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    btnAllFiles.checked = true
                    selPageIndex = 0
                }
            }
        }


        RadioButton {
            id:btnDownload
            width: parent.parent.width
            height: 50 * dpi
            background: Rectangle {
                color: btnDownload.checked ? "#3D414B" : "transparent"
                Row {
                    id:rowDownload
                    anchors.centerIn: parent
                    spacing: 10 * dpi

                    Image {
                        source: btnDownload.checked ? "../res/icon_download_sel.png" :
                                                     "../res/icon_download.png"
                        fillMode: Image.PreserveAspectFit
                        scale: dpi
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "正在下载"
                        font.pixelSize: 16 * dpi
                        color: btnDownload.checked ? "white" : "#818D9D"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    anchors.left: rowDownload.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: DownloadListModel.downloadNum
                    font.pixelSize: 16 * dpi
                    color: btnDownload.checked ? "white" : "#818D9D"
                }

            }

            indicator: Rectangle {
                color: "transparent"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    btnDownload.checked = true
                    selPageIndex = 1
                }
            }
        }

        RadioButton {
            id:btnUpload
            width: parent.parent.width
            height: 50 * dpi
            background: Rectangle {
                color: btnUpload.checked ? "#3D414B" : "transparent"
                Row {
                    id:rowUpload
                    anchors.centerIn: parent
                    spacing: 10 * dpi

                    Image {
                        source: btnUpload.checked ? "../res/icon_upload_sel.png" :
                                                     "../res/icon_upload.png"
                        fillMode: Image.PreserveAspectFit
                        scale: dpi
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "正在上传"
                        font.pixelSize: 16 * dpi
                        color: btnUpload.checked ? "white" : "#818D9D"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    anchors.left: rowUpload.right
                    anchors.verticalCenter: parent.verticalCenter
                    text:UploadListModel.uploadNum
                    font.pixelSize: 16 * dpi
                    color: btnUpload.checked ? "white" : "#818D9D"
                }

            }

            indicator: Rectangle {
                color: "transparent"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    btnUpload.checked = true
                    selPageIndex = 2
                }
            }
        }


        RadioButton {
            id:btnComplete
            width: parent.parent.width
            height: 50 * dpi
            background: Rectangle {
                color: btnComplete.checked ? "#3D414B" : "transparent"
                Row {
                    id:rowComplete
                    anchors.centerIn: parent
                    spacing: 10 * dpi

                    Image {
                        source: btnComplete.checked ? "../res/icon_complete_sel.png" :
                                                     "../res/icon_complete.png"
                        fillMode: Image.PreserveAspectFit
                        scale: dpi
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "传输完成"
                        font.pixelSize: 16 * dpi
                        color: btnComplete.checked ? "white" : "#818D9D"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    anchors.left: rowComplete.right
                    anchors.verticalCenter: parent.verticalCenter
                    text:CompleteListModel.completeNum
                    font.pixelSize: 16 * dpi
                    color: btnComplete.checked ? "white" : "#818D9D"
                }

            }

            indicator: Rectangle {
                color: "transparent"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    btnComplete.checked = true
                    selPageIndex = 3
                }
            }
        }


        // Repeater {
        //     model:listModel
        //     delegate: RadioButton {
        //         id:btnMenus
        //         width: parent.parent.width
        //         height: 50 * dpi
        //         checked:model.index === 0
        //         background: Rectangle {
        //             color: btnMenus.checked ? "#3D414B" : "transparent"
        //             Row {
        //                 id:rowAllFiles
        //                 anchors.centerIn: parent
        //                 spacing: 10 * dpi

        //                 Image {
        //                     source: btnMenus.checked ? selectImage : normalImage
        //                     fillMode: Image.PreserveAspectFit
        //                     scale: dpi
        //                     anchors.verticalCenter: parent.verticalCenter
        //                 }

        //                 Text {
        //                     text: captionText
        //                     font.pixelSize: 16 * dpi
        //                     color: btnMenus.checked ? "white" : "#818D9D"
        //                     anchors.verticalCenter: parent.verticalCenter
        //                 }
        //             }

        //             Text {
        //                 id:textTaskNum
        //                 anchors.left: rowAllFiles.right
        //                 anchors.verticalCenter: parent.verticalCenter
        //                 //text:"(30)"
        //                 font.pixelSize: 16 * dpi
        //                 color: btnMenus.checked ? "white" : "#818D9D"
        //                 visible: model.index !== 0
        //             }

        //         }

        //         indicator: Rectangle {
        //             color: "transparent"
        //         }

        //         MouseArea {
        //             anchors.fill: parent
        //             hoverEnabled: true
        //             cursorShape: Qt.PointingHandCursor
        //             onClicked: {
        //                 btnMenus.checked = true
        //                 selPageIndex = index
        //             }
        //         }
        //     }
        // }
    }

}


